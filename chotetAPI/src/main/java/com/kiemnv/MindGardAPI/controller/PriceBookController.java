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

    @PutMapping("/{id}")
    public ResponseEntity<PriceBookDto> updatePriceLog(@PathVariable Long id, @RequestBody PriceBookDto dto) {
        return ResponseEntity.ok(priceBookService.updatePriceLog(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePriceLog(@PathVariable Long id) {
        priceBookService.deletePriceLog(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/items/{itemName}")
    public ResponseEntity<Void> deleteItem(@PathVariable String itemName) {
        priceBookService.deleteItem(itemName);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/items/{oldName}")
    public ResponseEntity<Void> updateItem(
            @PathVariable String oldName,
            @RequestParam("newName") String newName,
            @RequestParam("newUnit") String newUnit,
            @RequestParam(value = "imageUrl", required = false) String imageUrl) {
        priceBookService.updateItem(oldName, newName, newUnit, imageUrl);
        return ResponseEntity.ok().build();
    }
}
