package com.kiemnv.MindGardAPI.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kiemnv.MindGardAPI.dto.ReceiptScannerDTOs.ReceiptScanResult;
import com.kiemnv.MindGardAPI.dto.ReceiptScannerDTOs.ScannedItem;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class GeminiService {

    @Value("${GEMINI_API_KEY}")
    private String apiKey;

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=";

    public ReceiptScanResult scanReceipt(byte[] imageBytes, String contentType, List<com.kiemnv.MindGardAPI.entity.ShoppingItem> plannedItems) {
        String base64Image = Base64.getEncoder().encodeToString(imageBytes);

        StringBuilder plannedItemsJson = new StringBuilder("[");
        if (plannedItems != null) {
            for (int i = 0; i < plannedItems.size(); i++) {
                com.kiemnv.MindGardAPI.entity.ShoppingItem item = plannedItems.get(i);
                plannedItemsJson.append(String.format("{\"id\": %d, \"name\": \"%s\", \"unit\": \"%s\"}", 
                        item.getId(), item.getName(), item.getUnit()));
                if (i < plannedItems.size() - 1) plannedItemsJson.append(",");
            }
        }
        plannedItemsJson.append("]");

        String prompt = "Phân tích hình ảnh hóa đơn này và trích xuất thông tin sản phẩm.\n" +
                "Tôi có danh sách các món đồ ứng viên (Candidate Items) để so khớp như sau: " + plannedItemsJson.toString() + "\n\n" +
                "Hãy thực hiện các bước sau:\n" +
                "1. Trích xuất tất cả món đồ từ hóa đơn: tên, giá đơn vị, số lượng, đơn vị tính.\n" +
                "2. Kết hợp với danh sách ứng viên (Candidate Items), trả về 'plannedItemId' nếu khớp.\n" +
                "   - Việc so khớp dựa trên ý nghĩa (ví dụ: 'Thịt bò' khớp với 'Thịt bò thăn').\n" +
                "3. Trích xuất tên cửa hàng (storeName) và địa chỉ cửa hàng (storeAddress) từ hóa đơn.\n" +
                "4. Trả về JSON theo cấu trúc sau:\n\n" +
                "Trả về JSON theo cấu trúc:\n" +
                "{\n" +
                "  \"items\": [\n" +
                "    {\"name\": \"...\", \"price\": 0.0, \"quantity\": 1.0, \"unit\": \"...\", \"plannedItemId\": 123 hoặc null}\n" +
                "  ],\n" +
                "  \"storeName\": \"...\",\n" +
                "  \"storeAddress\": \"...\",\n" +
                "  \"transactionDate\": \"yyyy-MM-dd'T'HH:mm:ss\"\n" +
                "}";

        Map<String, Object> request = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(
                                Map.of("text", prompt),
                                Map.of("inlineData", Map.of(
                                        "mimeType", contentType,
                                        "data", base64Image
                                ))
                        ))
                ),
                "generationConfig", Map.of(
                        "responseMimeType", "application/json"
                )
        );

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        try {
            ResponseEntity<String> response = restTemplate.postForEntity(GEMINI_API_URL + apiKey, entity, String.class);
            if (response.getStatusCode() == HttpStatus.OK) {
                return parseGeminiResponse(response.getBody());
            } else {
                log.error("Gemini API error: {} - {}", response.getStatusCode(), response.getBody());
                throw new RuntimeException("Failed to scan receipt with Gemini AI");
            }
        } catch (Exception e) {
            log.error("Error calling Gemini API", e);
            throw new RuntimeException("Error communicating with Gemini AI", e);
        }
    }

    private ReceiptScanResult parseGeminiResponse(String responseBody) {
        try {
            JsonNode root = objectMapper.readTree(responseBody);
            String jsonContent = root.path("candidates").get(0).path("content").path("parts").get(0).path("text").asText();
            
            // Clean markdown if present
            jsonContent = jsonContent.replaceAll("```json", "").replaceAll("```", "").trim();
            
            JsonNode resultNode = objectMapper.readTree(jsonContent);
            
            List<ScannedItem> items = new ArrayList<>();
            JsonNode itemsNode = resultNode.path("items");
            if (itemsNode.isArray()) {
                for (JsonNode itemNode : itemsNode) {
                    Long plannedId = null;
                    JsonNode pidNode = itemNode.path("plannedItemId");
                    if (!pidNode.isMissingNode() && !pidNode.isNull()) {
                        plannedId = pidNode.asLong();
                    }

                    items.add(ScannedItem.builder()
                            .name(itemNode.path("name").asText())
                            .price(new BigDecimal(itemNode.path("price").asText("0")))
                            .quantity(new BigDecimal(itemNode.path("quantity").asText("1")))
                            .unit(itemNode.path("unit").asText())
                            .plannedItemId(plannedId)
                            .build());
                }
            }
            
            return ReceiptScanResult.builder()
                    .items(items)
                    .storeName(resultNode.path("storeName").asText("Unknown Store"))
                    .storeAddress(resultNode.path("storeAddress").asText("Unknown Address"))
                    .transactionDate(resultNode.path("transactionDate").asText(null))
                    .build();
        } catch (Exception e) {
            log.error("Error parsing Gemini response: {}", responseBody, e);
            throw new RuntimeException("Failed to parse Gemini AI response", e);
        }
    }
}
