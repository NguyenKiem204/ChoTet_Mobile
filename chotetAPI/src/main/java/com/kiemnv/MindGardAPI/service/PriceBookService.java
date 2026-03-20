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
