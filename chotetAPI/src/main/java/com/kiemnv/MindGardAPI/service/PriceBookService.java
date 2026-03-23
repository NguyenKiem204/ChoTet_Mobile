package com.kiemnv.MindGardAPI.service;

import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.PriceBookDto;
import com.kiemnv.MindGardAPI.entity.PriceBook;
import com.kiemnv.MindGardAPI.repository.PriceBookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PriceBookService {

    private final PriceBookRepository priceBookRepository;

    @Transactional(readOnly = true)
    public List<PriceBookDto> getPricesByItemName(String itemName) {
        return priceBookRepository.findByItemNameIgnoreCaseOrderByObservedAtDesc(itemName).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PriceBookDto> getAllPrices() {
        return priceBookRepository.findAll().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public PriceBookDto addPriceLog(PriceBookDto dto) {
        PriceBook entity = PriceBook.builder()
                .itemName(dto.getItemName())
                .storeName(dto.getStoreName())
                .unit(dto.getUnit())
                .price(dto.getPrice())
                .imageUrl(dto.getImageUrl())
                .sourceListId(dto.getSourceListId())
                .observedAt(dto.getObservedAt() != null ? dto.getObservedAt() : LocalDateTime.now())
                .build();

        return mapToDto(priceBookRepository.save(entity));
    }

    @Transactional
    public void deletePriceLog(Long id) {
        priceBookRepository.deleteById(id);
    }

    @Transactional
    public void deleteItem(String itemName) {
        List<PriceBook> logs = priceBookRepository.findByItemNameIgnoreCaseOrderByObservedAtDesc(itemName);
        priceBookRepository.deleteAll(logs);
    }

    @Transactional
    public void updateItem(String oldName, String newName, String newUnit, String imageUrl) {
        List<PriceBook> logs = priceBookRepository.findByItemNameIgnoreCaseOrderByObservedAtDesc(oldName);
        for (PriceBook log : logs) {
            log.setItemName(newName);
            log.setUnit(newUnit);
            if (imageUrl != null && !imageUrl.isEmpty()) {
                log.setImageUrl(imageUrl);
            }
        }
        priceBookRepository.saveAll(logs);
    }

    @Transactional
    public PriceBookDto updatePriceLog(Long id, PriceBookDto dto) {
        PriceBook entity = priceBookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Price log not found"));
        
        entity.setStoreName(dto.getStoreName());
        entity.setPrice(dto.getPrice());
        entity.setUnit(dto.getUnit());
        if (dto.getObservedAt() != null) entity.setObservedAt(dto.getObservedAt());
        
        return mapToDto(priceBookRepository.save(entity));
    }

    private PriceBookDto mapToDto(PriceBook entity) {
        return PriceBookDto.builder()
                .id(entity.getId())
                .itemName(entity.getItemName())
                .storeName(entity.getStoreName())
                .unit(entity.getUnit())
                .price(entity.getPrice())
                .imageUrl(entity.getImageUrl())
                .sourceListId(entity.getSourceListId())
                .observedAt(entity.getObservedAt())
                .build();
    }
}
