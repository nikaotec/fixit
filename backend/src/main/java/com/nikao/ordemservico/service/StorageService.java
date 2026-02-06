package com.nikao.ordemservico.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
public class StorageService {

    @Value("${app.storage.base-path:./storage}")
    private String basePath;

    public String store(byte[] content, String relativePath) {
        try {
            Path target = Paths.get(basePath, relativePath);
            Files.createDirectories(target.getParent());
            Files.write(target, content);
            return target.toString();
        } catch (IOException e) {
            throw new IllegalStateException("Nao foi possivel armazenar arquivo", e);
        }
    }

    public byte[] read(String storedPath) {
        try {
            return Files.readAllBytes(Paths.get(storedPath));
        } catch (IOException e) {
            throw new IllegalStateException("Nao foi possivel ler arquivo", e);
        }
    }
}
