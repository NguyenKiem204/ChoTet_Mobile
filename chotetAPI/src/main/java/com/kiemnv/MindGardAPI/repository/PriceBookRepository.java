package com.kiemnv.MindGardAPI.repository;

import com.kiemnv.MindGardAPI.entity.PriceBook;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PriceBookRepository extends JpaRepository<PriceBook, Long> {
    List<PriceBook> findByItemNameIgnoreCase(String itemName);
    List<PriceBook> findByItemNameIgnoreCaseOrderByObservedAtDesc(String itemName);
}
