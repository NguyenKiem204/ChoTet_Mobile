package com.kiemnv.MindGardAPI.controller;

import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.ShoppingListDto;
import com.kiemnv.MindGardAPI.dto.request.ShareListRequest;
import com.kiemnv.MindGardAPI.service.ShoppingListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/shopping-lists")
@RequiredArgsConstructor
public class ShoppingListController {

    private final ShoppingListService shoppingListService;

    // TODO: In real implementation, extract userId from Authentication context (JWT)
    // For now, accepting it as a header or param for simple testing
    @GetMapping
    public ResponseEntity<List<ShoppingListDto>> getUserShoppingLists(@RequestHeader("user-id") Long userId) {
        return ResponseEntity.ok(shoppingListService.getShoppingListsByUserId(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShoppingListDto> getShoppingListById(@PathVariable Long id) {
        return ResponseEntity.ok(shoppingListService.getShoppingListById(id));
    }

    @PostMapping
    public ResponseEntity<ShoppingListDto> createShoppingList(
            @RequestHeader("user-id") Long userId,
            @RequestBody ShoppingListDto dto) {
        return new ResponseEntity<>(shoppingListService.createShoppingList(userId, dto), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ShoppingListDto> updateShoppingList(
            @PathVariable Long id,
            @RequestBody ShoppingListDto dto) {
        return ResponseEntity.ok(shoppingListService.updateShoppingList(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteShoppingList(@PathVariable Long id) {
        shoppingListService.deleteShoppingList(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/share")
    public ResponseEntity<ShoppingListDto> shareShoppingList(
            @PathVariable Long id,
            @RequestBody ShareListRequest request) {
        return ResponseEntity.ok(shoppingListService.shareListWithUser(id, request.getUsernameOrEmail()));
    }

    @DeleteMapping("/{id}/share/{userId}")
    public ResponseEntity<ShoppingListDto> unshareShoppingList(
            @PathVariable Long id,
            @PathVariable Long userId) {
        return ResponseEntity.ok(shoppingListService.unshareListWithUser(id, userId));
    }
}
