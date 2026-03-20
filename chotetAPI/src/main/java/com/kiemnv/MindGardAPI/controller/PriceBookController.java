package com.kiemnv.MindGardAPI.controller;

import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.PriceBookDto;
import com.kiemnv.MindGardAPI.service.PriceBookService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/price-book")
@RequiredArgsConstructor
public class PriceBookController {

    private final PriceBookService priceBookService;

    @GetMapping
    public ResponseEntity<List<PriceBookDto>> getAllPrices() {
        return ResponseEntity.ok(priceBookService.getAllPrices());
    }

    @GetMapping("/search")
    public ResponseEntity<List<PriceBookDto>> searchPricesByItemName(@RequestParam("itemName") String itemName) {
        return ResponseEntity.ok(priceBookService.getPricesByItemName(itemName));
    }

    @PostMapping
    public ResponseEntity<PriceBookDto> addPriceLog(@RequestBody PriceBookDto dto) {
        return new ResponseEntity<>(priceBookService.addPriceLog(dto), HttpStatus.CREATED);
    }
}
