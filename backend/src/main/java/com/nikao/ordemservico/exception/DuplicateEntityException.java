package com.nikao.ordemservico.exception;

import lombok.Getter;

import java.util.UUID;

@Getter
public class DuplicateEntityException extends RuntimeException {
    private final UUID conflictId;

    public DuplicateEntityException(String message, UUID conflictId) {
        super(message);
        this.conflictId = conflictId;
    }
}
