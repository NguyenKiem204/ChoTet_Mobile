package com.kiemnv.MindGardAPI.service;

import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.ShoppingItemDto;
import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.UserShortDto;
import com.kiemnv.MindGardAPI.entity.ShoppingItem;
import com.kiemnv.MindGardAPI.entity.ShoppingList;
import com.kiemnv.MindGardAPI.entity.User;
import com.kiemnv.MindGardAPI.repository.ShoppingItemRepository;
import com.kiemnv.MindGardAPI.repository.ShoppingListRepository;
import com.kiemnv.MindGardAPI.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ShoppingItemService {

    private final ShoppingItemRepository shoppingItemRepository;
    private final ShoppingListRepository shoppingListRepository;
    private final UserRepository userRepository;

    @Transactional
    public ShoppingItemDto addItemToList(Long listId, ShoppingItemDto dto) {
        ShoppingList list = shoppingListRepository.findById(listId)
                .orElseThrow(() -> new RuntimeException("Shopping list not found"));

        ShoppingItem item = ShoppingItem.builder()
                .shoppingList(list)
                .name(dto.getName())
                .quantity(dto.getQuantity() != null ? dto.getQuantity() : BigDecimal.ONE)
                .unit(dto.getUnit())
                .estimatedPrice(dto.getEstimatedPrice() != null ? dto.getEstimatedPrice() : BigDecimal.ZERO)
                .actualPrice(dto.getActualPrice() != null ? dto.getActualPrice() : BigDecimal.ZERO)
                .isPurchased(dto.getIsPurchased() != null ? dto.getIsPurchased() : false)
                .isExtra(dto.getIsExtra() != null ? dto.getIsExtra() : false)
                .imageUrl(dto.getImageUrl())
                .category(dto.getCategory())
                .scheduledDate(dto.getScheduledDate())
                .note(dto.getNote())
                .build();

        ShoppingItem saved = shoppingItemRepository.save(item);
        updateListTotals(list);
        return mapToDto(saved);
    }

    @Transactional
    public ShoppingItemDto updateItem(Long id, ShoppingItemDto dto, Long actingUserId) {
        ShoppingItem item = shoppingItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shopping item not found"));

        if (dto.getName() != null) item.setName(dto.getName());
        if (dto.getQuantity() != null) item.setQuantity(dto.getQuantity());
        if (dto.getUnit() != null) item.setUnit(dto.getUnit());
        if (dto.getEstimatedPrice() != null) item.setEstimatedPrice(dto.getEstimatedPrice());
        if (dto.getActualPrice() != null) item.setActualPrice(dto.getActualPrice());
        
        if (dto.getIsPurchased() != null) {
            boolean wasPurchased = item.getIsPurchased();
            item.setIsPurchased(dto.getIsPurchased());
            
            if (dto.getIsPurchased() && !wasPurchased && actingUserId != null) {
                User user = userRepository.findById(actingUserId)
                        .orElseThrow(() -> new RuntimeException("User not found"));
                item.setPurchasedBy(user);
            } else if (!dto.getIsPurchased()) {
                item.setPurchasedBy(null);
            }
        }
        if (dto.getIsExtra() != null) item.setIsExtra(dto.getIsExtra());
        if (dto.getImageUrl() != null) item.setImageUrl(dto.getImageUrl());
        if (dto.getCategory() != null) item.setCategory(dto.getCategory());
        if (dto.getScheduledDate() != null) item.setScheduledDate(dto.getScheduledDate());
        if (dto.getNote() != null) item.setNote(dto.getNote());

        ShoppingItem saved = shoppingItemRepository.save(item);
        updateListTotals(item.getShoppingList());
        return mapToDto(saved);
    }

    @Transactional
    public void deleteItem(Long id) {
        ShoppingItem item = shoppingItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shopping item not found"));
        ShoppingList list = item.getShoppingList();
        
        // Explicitly remove from the collection to avoid Hibernate merge issues
        list.getItems().remove(item);
        
        shoppingItemRepository.delete(item);
        updateListTotals(list);
    }

    private void updateListTotals(ShoppingList list) {
        // Recalculate totals
        BigDecimal totalEst = list.getItems().stream()
                .map(i -> i.getEstimatedPrice().multiply(i.getQuantity()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        BigDecimal totalAct = list.getItems().stream()
                .filter(ShoppingItem::getIsPurchased)
                .map(i -> i.getActualPrice().multiply(i.getQuantity()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        list.setTotalEstimated(totalEst);
        list.setTotalActual(totalAct);
        shoppingListRepository.save(list);
    }

    public ShoppingItemDto mapToDto(ShoppingItem item) {
        return ShoppingItemDto.builder()
                .id(item.getId())
                .listId(item.getShoppingList().getId())
                .name(item.getName())
                .quantity(item.getQuantity())
                .unit(item.getUnit())
                .estimatedPrice(item.getEstimatedPrice())
                .actualPrice(item.getActualPrice())
                .isPurchased(item.getIsPurchased())
                .isExtra(item.getIsExtra())
                .imageUrl(item.getImageUrl())
                .category(item.getCategory())
                .scheduledDate(item.getScheduledDate())
                .note(item.getNote())
                .purchasedBy(item.getPurchasedBy() != null ? UserShortDto.builder()
                        .id(item.getPurchasedBy().getId())
                        .username(item.getPurchasedBy().getUsername())
                        .firstName(item.getPurchasedBy().getFirstName())
                        .lastName(item.getPurchasedBy().getLastName())
                        .avatarUrl(item.getPurchasedBy().getAvatarUrl())
                        .imageUrl(item.getPurchasedBy().getImageUrl())
                        .build() : null)
                .createdAt(item.getCreatedAt())
                .updatedAt(item.getUpdatedAt())
                .build();
    }
}
