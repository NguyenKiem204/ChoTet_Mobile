package com.kiemnv.MindGardAPI.service;

import com.kiemnv.MindGardAPI.exception.ResourceNotFoundException;
import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.ShoppingListDto;
import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.ShoppingItemDto;
import com.kiemnv.MindGardAPI.dto.ShoppingDTOs.UserShortDto;
import com.kiemnv.MindGardAPI.entity.ShoppingList;
import com.kiemnv.MindGardAPI.entity.User;
import com.kiemnv.MindGardAPI.repository.ShoppingListRepository;
import com.kiemnv.MindGardAPI.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ShoppingListService {

    private final ShoppingListRepository shoppingListRepository;
    private final UserRepository userRepository;
    private final ShoppingItemService shoppingItemService;

    @Transactional(readOnly = true)
    public List<ShoppingListDto> getShoppingListsByUserId(Long userId) {
        return shoppingListRepository.findByUserIdOrSharedUsersIdOrderByScheduledDateAsc(userId).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ShoppingListDto getShoppingListById(Long id) {
        ShoppingList list = shoppingListRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shopping list not found"));
        return mapToDto(list);
    }

    @Transactional
    public ShoppingListDto createShoppingList(Long userId, ShoppingListDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        ShoppingList entity = ShoppingList.builder()
                .user(user)
                .name(dto.getName())
                .budget(dto.getBudget())
                .scheduledDate(dto.getScheduledDate())
                .imageUrl(dto.getImageUrl())
                .status(dto.getStatus() != null ? dto.getStatus() : "PLANNED")
                .items(new ArrayList<>())
                .build();

        if (dto.getItems() != null && !dto.getItems().isEmpty()) {
            dto.getItems().forEach(itemDto -> {
                com.kiemnv.MindGardAPI.entity.ShoppingItem item = com.kiemnv.MindGardAPI.entity.ShoppingItem.builder()
                        .shoppingList(entity)
                        .name(itemDto.getName())
                        .quantity(itemDto.getQuantity() != null ? itemDto.getQuantity() : java.math.BigDecimal.ONE)
                        .unit(itemDto.getUnit())
                        .estimatedPrice(itemDto.getEstimatedPrice() != null ? itemDto.getEstimatedPrice() : java.math.BigDecimal.ZERO)
                        .isPurchased(false)
                        .isExtra(false)
                        .scheduledDate(itemDto.getScheduledDate())
                        .build();
                entity.getItems().add(item);
            });
        }

        ShoppingList saved = shoppingListRepository.save(entity);
        return mapToDto(saved);
    }

    @Transactional
    public ShoppingListDto updateShoppingList(Long id, ShoppingListDto dto) {
        ShoppingList entity = shoppingListRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh sách mua sắm"));

        if (dto.getName() != null) entity.setName(dto.getName());
        if (dto.getBudget() != null) entity.setBudget(dto.getBudget());
        if (dto.getScheduledDate() != null) entity.setScheduledDate(dto.getScheduledDate());
        if (dto.getImageUrl() != null) entity.setImageUrl(dto.getImageUrl());
        if (dto.getStatus() != null) entity.setStatus(dto.getStatus());

        return mapToDto(shoppingListRepository.save(entity));
    }

    @Transactional
    public void deleteShoppingList(Long id) {
        shoppingListRepository.deleteById(id);
    }

    @Transactional
    public ShoppingListDto shareListWithUser(Long listId, String usernameOrEmail) {
        ShoppingList list = shoppingListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh sách mua sắm"));

        User user = userRepository.findByUsername(usernameOrEmail)
                .or(() -> userRepository.findByEmail(usernameOrEmail))
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng với email hoặc tên đăng nhập: " + usernameOrEmail));

        if (list.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Bạn không thể tự chia sẻ danh sách cho chính mình");
        }

        list.getSharedUsers().add(user);
        return mapToDto(shoppingListRepository.save(list));
    }

    @Transactional
    public ShoppingListDto unshareListWithUser(Long listId, Long userId) {
        ShoppingList list = shoppingListRepository.findById(listId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy danh sách mua sắm"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        list.getSharedUsers().remove(user);
        return mapToDto(shoppingListRepository.save(list));
    }

    private ShoppingListDto mapToDto(ShoppingList entity) {
        List<ShoppingItemDto> itemDtos = entity.getItems().stream()
                .map(shoppingItemService::mapToDto)
                .collect(Collectors.toList());

        return ShoppingListDto.builder()
                .id(entity.getId())
                .userId(entity.getUser().getId())
                .name(entity.getName())
                .budget(entity.getBudget())
                .totalEstimated(entity.getTotalEstimated())
                .totalActual(entity.getTotalActual())
                .scheduledDate(entity.getScheduledDate())
                .imageUrl(entity.getImageUrl())
                .status(entity.getStatus())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .items(itemDtos)
                .sharedUsers(entity.getSharedUsers().stream()
                        .map(user -> UserShortDto.builder()
                                .id(user.getId())
                                .username(user.getUsername())
                                .firstName(user.getFirstName())
                                .lastName(user.getLastName())
                                .nickname(user.getNickname())
                                .avatarUrl(user.getAvatarUrl())
                                .imageUrl(user.getImageUrl())
                                .build())
                        .collect(Collectors.toSet()))
                .build();
    }
}
