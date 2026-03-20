package com.kiemnv.MindGardAPI.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "price_book")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = false)
public class PriceBook {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "item_name", nullable = false)
    private String itemName;

    @Column(name = "store_name")
    private String storeName;

    @Column(name = "store_address", length = 500)
    private String storeAddress;

    @Column(length = 50)
    private String unit;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @Column(name = "source_list_id")
    private Long sourceListId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "source_list_id", insertable = false, updatable = false)
    @ToString.Exclude
    private ShoppingList sourceList;

    @Column(name = "observed_at")
    @Builder.Default
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
    private LocalDateTime observedAt = LocalDateTime.now();

    @PrePersist
    public void prePersist() {
        if (observedAt == null) observedAt = LocalDateTime.now();
    }
}
