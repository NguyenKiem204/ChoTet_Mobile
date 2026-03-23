package com.kiemnv.MindGardAPI.controller;

import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.ShoppingListDto;
import com.kiemnv.MindGardAPI.dto.request.ShareListRequest;
import com.kiemnv.MindGardAPI.entity.User;
import com.kiemnv.MindGardAPI.service.ShoppingListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import org.springframework.web.multipart.MultipartFile;
import com.kiemnv.MindGardAPI.dto.response.ApiResponse;
import com.kiemnv.MindGardAPI.service.CloudinaryService;

@RestController
@RequestMapping("/api/v1/shopping-lists")
@RequiredArgsConstructor
public class ShoppingListController {

    private final ShoppingListService shoppingListService;
    private final CloudinaryService cloudinaryService;

    @GetMapping
    public ResponseEntity<List<ShoppingListDto>> getUserShoppingLists(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(shoppingListService.getShoppingListsByUserId(user.getId()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShoppingListDto> getShoppingListById(@PathVariable Long id) {
        return ResponseEntity.ok(shoppingListService.getShoppingListById(id));
    }

    @PostMapping
    public ResponseEntity<ShoppingListDto> createShoppingList(
            @AuthenticationPrincipal User user,
            @RequestBody ShoppingListDto dto) {
        return new ResponseEntity<>(shoppingListService.createShoppingList(user.getId(), dto), HttpStatus.CREATED);
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

    @PostMapping("/upload-image")
    public ResponseEntity<ApiResponse<String>> uploadImage(
            @RequestParam("file") MultipartFile file) {
        String url = cloudinaryService.uploadImage(file, "shopping_lists");
        return ResponseEntity.ok(ApiResponse.success(url, "Image uploaded successfully"));
    }
}
