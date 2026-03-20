package com.kiemnv.MindGardAPI.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "shopping_items")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class ShoppingItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "list_id", nullable = false)
    @JsonIgnoreProperties("items")
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private ShoppingList shoppingList;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "purchased_by_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "roles", "authorities", "provider", "status", "firstName", "lastName", "phoneNumber", "createdAt", "updatedAt", "lastLogin", "email", "password"})
    private User purchasedBy;

    @Column(nullable = false)
    private String name;

    @Column(precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal quantity = BigDecimal.ONE;

    @Column(length = 50)
    private String unit;

    @Column(name = "estimated_price", precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal estimatedPrice = BigDecimal.ZERO;

    @Column(name = "actual_price", precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal actualPrice = BigDecimal.ZERO;

    @Column(name = "is_purchased")
    @Builder.Default
    private Boolean isPurchased = false;

    @Column(name = "is_extra")
    @Builder.Default
    private Boolean isExtra = false;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(length = 100)
    private String category;

    @Column(name = "scheduled_date")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate scheduledDate;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "created_at")
    @Builder.Default
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "updated_at")
    @Builder.Default
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
    private LocalDateTime updatedAt = LocalDateTime.now();

    @PrePersist
    public void prePersist() {
        if (createdAt == null) createdAt = LocalDateTime.now();
        if (updatedAt == null) updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
