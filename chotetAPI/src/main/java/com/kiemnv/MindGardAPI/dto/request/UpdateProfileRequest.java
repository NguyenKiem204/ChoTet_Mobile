package com.kiemnv.MindGardAPI.dto.request;

import lombok.Data;

@Data
public class UpdateProfileRequest {
    private String firstName;
    private String lastName;
    private String nickname;
    private String avatarUrl;
}
