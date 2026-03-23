package com.kiemnv.MindGardAPI.controller;

import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.ShoppingItemDto;
import com.kiemnv.MindGardAPI.entity.User;
import com.kiemnv.MindGardAPI.service.ShoppingItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/shopping-lists/{listId}/items")
@RequiredArgsConstructor
public class ShoppingItemController {

    private final ShoppingItemService shoppingItemService;

    @PostMapping
    public ResponseEntity<ShoppingItemDto> addItem(
            @AuthenticationPrincipal User user,
            @PathVariable Long listId,
            @RequestBody ShoppingItemDto dto) {
        return new ResponseEntity<>(shoppingItemService.addItemToList(listId, dto, user.getId()), HttpStatus.CREATED);
    }

    @PutMapping("/{itemId}")
    public ResponseEntity<ShoppingItemDto> updateItem(
            @AuthenticationPrincipal User user,
            @PathVariable Long listId,
            @PathVariable Long itemId,
            @RequestBody ShoppingItemDto dto) {
        return ResponseEntity.ok(shoppingItemService.updateItem(itemId, dto, user.getId()));
    }

    @DeleteMapping("/{itemId}")
    public ResponseEntity<Void> deleteItem(
            @PathVariable Long listId,
            @PathVariable Long itemId) {
        shoppingItemService.deleteItem(itemId);
        return ResponseEntity.noContent().build();
    }
}

