package com.kiemnv.MindGardAPI.repository;

import com.kiemnv.MindGardAPI.entity.ShoppingList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ShoppingListRepository extends JpaRepository<ShoppingList, Long> {
    List<ShoppingList> findByUserId(Long userId);
    List<ShoppingList> findByUserIdOrderByScheduledDateAsc(Long userId);

    @Query("SELECT sl FROM ShoppingList sl LEFT JOIN sl.sharedUsers su WHERE sl.user.id = :userId OR su.id = :userId ORDER BY sl.scheduledDate ASC")
    List<ShoppingList> findByUserIdOrSharedUsersIdOrderByScheduledDateAsc(Long userId);
}
