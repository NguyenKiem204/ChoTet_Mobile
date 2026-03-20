package com.kiemnv.MindGardAPI.repository;

import com.kiemnv.MindGardAPI.entity.ShoppingItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface ShoppingItemRepository extends JpaRepository<ShoppingItem, Long> {
    List<ShoppingItem> findByShoppingListId(Long listId);
    List<ShoppingItem> findByShoppingListIdAndScheduledDate(Long listId, LocalDate date);

    @org.springframework.data.jpa.repository.Query("SELECT i FROM ShoppingItem i WHERE i.shoppingList.user.id = :userId AND (i.isPurchased = false OR i.updatedAt >= :since)")
    List<ShoppingItem> findCandidateItemsByUserId(@org.springframework.data.repository.query.Param("userId") Long userId, @org.springframework.data.repository.query.Param("since") java.time.LocalDateTime since);
}
