package com.kiemnv.MindGardAPI.controller;

import com.kiemnv.MindGardAPI.dto.ReceiptScannerDTOs.ScanResponse;
import com.kiemnv.MindGardAPI.dto.response.ApiResponse;
import com.kiemnv.MindGardAPI.service.ReceiptScannerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/receipt-scanner")
@RequiredArgsConstructor
@Tag(name = "AI Receipt Scanner", description = "Endpoints for scanning receipts using AI")
public class ReceiptScannerController {

    private final ReceiptScannerService receiptScannerService;

    @PostMapping("/scan/{listId}")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "Quét hóa đơn bằng AI", description = "Tải lên hình ảnh hóa đơn để tự động cập nhật danh sách mua sắm.")
    public ResponseEntity<ApiResponse<ScanResponse>> scanReceipt(
            @PathVariable Long listId,
            @RequestParam("file") MultipartFile file) {
        
        ScanResponse result = receiptScannerService.scanAndProcessReceipt(listId, file);
        return ResponseEntity.ok(ApiResponse.success(result, "Đã quét và cập nhật danh sách thành công"));
    }
}
