package com.kiemnv.MindGardAPI.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

public class ReceiptScannerDTOs {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ScannedItem {
        private String name;
        private BigDecimal price;
        private BigDecimal quantity;
        private String unit;
        private Long plannedItemId; // Added for AI matching
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ReceiptScanResult {
        private List<ScannedItem> items;
        private String storeName;
        private String storeAddress;
        private String transactionDate; // ISO format or similar
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ScanResponse {
        private List<ScannedItemUpdate> updatedItems;
        private List<ScannedItemUpdate> extraItems;
        private BigDecimal totalNewExpenses;
        private String storeName; // Added to pass store name to UI
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ScannedItemUpdate {
        private Long id;
        private String name;
        private BigDecimal price;
        private BigDecimal quantity;
        private boolean isExtra;
        private String status;
        private String listName; // Added for UI feedback
    }
}
