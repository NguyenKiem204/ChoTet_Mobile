package com.kiemnv.MindGardAPI.controller;

import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.ShoppingItemDto;
import com.kiemnv.MindGardAPI.service.ShoppingItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/shopping-lists/{listId}/items")
@RequiredArgsConstructor
public class ShoppingItemController {

    private final ShoppingItemService shoppingItemService;

    @PostMapping
    public ResponseEntity<ShoppingItemDto> addItem(
            @PathVariable Long listId,
            @RequestBody ShoppingItemDto dto) {
        return new ResponseEntity<>(shoppingItemService.addItemToList(listId, dto), HttpStatus.CREATED);
    }

    @PutMapping("/{itemId}")
    public ResponseEntity<ShoppingItemDto> updateItem(
            @RequestHeader(value = "user-id", required = false) Long userId,
            @PathVariable Long listId,
            @PathVariable Long itemId,
            @RequestBody ShoppingItemDto dto) {
        // Technically listId is in the path for logical grouping, but itemId uniquely identifies the item
        return ResponseEntity.ok(shoppingItemService.updateItem(itemId, dto, userId));
    }

    @DeleteMapping("/{itemId}")
    public ResponseEntity<Void> deleteItem(
            @PathVariable Long listId,
            @PathVariable Long itemId) {
        shoppingItemService.deleteItem(itemId);
        return ResponseEntity.noContent().build();
    }
}
