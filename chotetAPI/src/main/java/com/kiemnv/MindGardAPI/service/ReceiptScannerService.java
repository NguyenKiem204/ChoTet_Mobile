package com.kiemnv.MindGardAPI.service;

import com.kiemnv.MindGardAPI.dto.ReceiptScannerDTOs.*;
import com.kiemnv.MindGardAPI.entity.PriceBook;
import com.kiemnv.MindGardAPI.entity.ShoppingItem;
import com.kiemnv.MindGardAPI.entity.ShoppingList;
import com.kiemnv.MindGardAPI.repository.PriceBookRepository;
import com.kiemnv.MindGardAPI.repository.ShoppingItemRepository;
import com.kiemnv.MindGardAPI.repository.ShoppingListRepository;
import com.kiemnv.MindGardAPI.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReceiptScannerService {

    private final GeminiService geminiService;
    private final CloudinaryService cloudinaryService;
    private final ShoppingItemRepository shoppingItemRepository;
    private final ShoppingListRepository shoppingListRepository;
    private final PriceBookRepository priceBookRepository;

    @Transactional
    public ScanResponse scanAndProcessReceipt(Long listId, MultipartFile file) {
        ShoppingList currentList = shoppingListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh sách mua sắm"));
        Long userId = currentList.getUser().getId();

        try {
            // 1. Upload image to Cloudinary (Optional - don't crash if it fails)
            String imageUrl = null;
            try {
                imageUrl = cloudinaryService.uploadImage(file, "receipts");
            } catch (Exception e) {
                log.error("Cloudinary upload failed, continuing without image: {}", e.getMessage());
            }

            // 2. Fetch all unpurchased items OR items purchased in the last 12 hours for matching
            // This prevents duplicate "Extra" items if the same receipt is scanned twice.
            LocalDateTime recently = LocalDateTime.now().minusHours(12);
            List<ShoppingItem> plannedItems = shoppingItemRepository.findCandidateItemsByUserId(userId, recently);

            // 3. Scan receipt with Gemini with smart matching
            ReceiptScanResult scanResult = geminiService.scanReceipt(file.getBytes(), file.getContentType(), plannedItems);

            List<ScannedItemUpdate> updatedItems = new ArrayList<>();
            List<ScannedItemUpdate> extraItems = new ArrayList<>();
            BigDecimal totalNewExpenses = BigDecimal.ZERO;

            for (ScannedItem scanned : scanResult.getItems()) {
                if (scanned.getPlannedItemId() != null) {
                    // Match found by AI
                    Optional<ShoppingItem> match = shoppingItemRepository.findById(scanned.getPlannedItemId());
                    if (match.isPresent()) {
                        ShoppingItem item = match.get();
                        
                        // If already purchased, don't add as extra and don't re-mark as purchased 
                        // unless we want to allow price updates. For now, let's just skip to prevent duplicates.
                        if (item.getIsPurchased()) {
                            log.info("Item '{}' (ID: {}) already purchased, skipping duplicate update", item.getName(), item.getId());
                            // Add to updated list so UI sees it was "handled" but don't save/increment totals
                            updatedItems.add(mapToUpdate(item));
                            continue;
                        }

                        item.setActualPrice(scanned.getPrice());
                        item.setQuantity(scanned.getQuantity()); 
                        item.setIsPurchased(true);
                        shoppingItemRepository.save(item);

                        updatedItems.add(mapToUpdate(item));
                        
                        // Also update the parent list totals if it's a different list
                        if (!item.getShoppingList().getId().equals(listId)) {
                            updateListTotals(item.getShoppingList());
                        }
                    }
                } else {
                    // Item not in any list, add as extra to the CURRENT list
                    ShoppingItem extra = ShoppingItem.builder()
                            .shoppingList(currentList)
                            .name(scanned.getName())
                            .quantity(scanned.getQuantity())
                            .unit(scanned.getUnit())
                            .actualPrice(scanned.getPrice())
                            .estimatedPrice(scanned.getPrice()) 
                            .isPurchased(true)
                            .isExtra(true)
                            .scheduledDate(currentList.getScheduledDate())
                            .build();
                    
                    ShoppingItem savedExtra = shoppingItemRepository.save(extra);
                    extraItems.add(mapToUpdate(savedExtra));
                    totalNewExpenses = totalNewExpenses.add(scanned.getPrice().multiply(scanned.getQuantity()));
                }

                // 4. Add to PriceBook
                LocalDateTime observedAt = LocalDateTime.now();
                if (scanResult.getTransactionDate() != null) {
                    try {
                        observedAt = LocalDateTime.parse(scanResult.getTransactionDate(), DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                    } catch (Exception e) {
                        log.warn("Could not parse transaction date: {}, using current time", scanResult.getTransactionDate());
                    }
                }

                PriceBook priceEntry = PriceBook.builder()
                        .itemName(scanned.getName())
                        .storeName(scanResult.getStoreName())
                        .storeAddress(scanResult.getStoreAddress())
                        .unit(scanned.getUnit())
                        .price(scanned.getPrice())
                        .imageUrl(imageUrl)
                        .sourceListId(listId)
                        .observedAt(observedAt)
                        .build();
                priceBookRepository.save(priceEntry);
            }

            // Update current list totals
            updateListTotals(currentList);

            return ScanResponse.builder()
                    .updatedItems(updatedItems)
                    .extraItems(extraItems)
                    .totalNewExpenses(totalNewExpenses)
                    .build();

        } catch (Exception e) {
            log.error("Error processing receipt", e);
            throw new RuntimeException("Lỗi khi xử lý hóa đơn: " + e.getMessage());
        }
    }

    private ScannedItemUpdate mapToUpdate(ShoppingItem item) {
        return ScannedItemUpdate.builder()
                .id(item.getId())
                .name(item.getName())
                .price(item.getActualPrice())
                .quantity(item.getQuantity())
                .isExtra(item.getIsExtra())
                .status("PURCHASED")
                .listName(item.getShoppingList().getName())
                .build();
    }

    private void updateListTotals(ShoppingList list) {
        List<ShoppingItem> items = shoppingItemRepository.findByShoppingListId(list.getId());
        
        BigDecimal totalEst = items.stream()
                .map(i -> (i.getEstimatedPrice() != null ? i.getEstimatedPrice() : BigDecimal.ZERO)
                        .multiply(i.getQuantity() != null ? i.getQuantity() : BigDecimal.ONE))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal totalAct = items.stream()
                .filter(ShoppingItem::getIsPurchased)
                .map(i -> (i.getActualPrice() != null ? i.getActualPrice() : BigDecimal.ZERO)
                        .multiply(i.getQuantity() != null ? i.getQuantity() : BigDecimal.ONE))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        list.setTotalEstimated(totalEst);
        list.setTotalActual(totalAct);
        shoppingListRepository.save(list);
    }
}
