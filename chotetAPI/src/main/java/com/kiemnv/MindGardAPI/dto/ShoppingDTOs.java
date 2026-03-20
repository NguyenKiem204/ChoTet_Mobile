package com.kiemnv.MindGardAPI.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ShoppingDTOs {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ShoppingListDto {
        private Long id;
        private Long userId;
        private String name;
        private BigDecimal budget;
        private BigDecimal totalEstimated;
        private BigDecimal totalActual;
        @JsonFormat(pattern = "yyyy-MM-dd")
        private LocalDate scheduledDate;
        private String imageUrl;
        private String status;
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
        private LocalDateTime createdAt;
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
        private LocalDateTime updatedAt;
        @Builder.Default
        private List<ShoppingItemDto> items = new ArrayList<>();
        @Builder.Default
        private Set<UserShortDto> sharedUsers = new HashSet<>();
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserShortDto {
        private Long id;
        private String username;
        private String firstName;
        private String lastName;
        private String nickname;
        private String avatarUrl;
        private String imageUrl;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ShoppingItemDto {
        private Long id;
        private Long listId;
        private String name;
        private BigDecimal quantity;
        private String unit;
        private BigDecimal estimatedPrice;
        private BigDecimal actualPrice;
        private Boolean isPurchased;
        private Boolean isExtra;
        private String imageUrl;
        private String category;
        @JsonFormat(pattern = "yyyy-MM-dd")
        private LocalDate scheduledDate;
        private String note;
        private UserShortDto purchasedBy;
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
        private LocalDateTime createdAt;
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
        private LocalDateTime updatedAt;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PriceBookDto {
        private Long id;
        private String itemName;
        private String storeName;
        private String unit;
        private BigDecimal price;
        private String imageUrl;
        private Long sourceListId;
        @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
        private LocalDateTime observedAt;
    }
}
