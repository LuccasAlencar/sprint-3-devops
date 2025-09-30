package com.mottu.sprint3.dto;

import com.mottu.sprint3.model.Zona;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class ZonaDto {
    private Long id;
    
    @NotBlank(message = "Nome da zona é obrigatório")
    @Size(min = 2, max = 100, message = "Nome deve ter entre 2 e 100 caracteres")
    private String nome;
    
    @NotBlank(message = "Letra da zona é obrigatória")
    @Pattern(regexp = "^[A-Z]$", message = "Letra deve ser uma única letra maiúscula")
    private String letra;

    public ZonaDto() {}

    public ZonaDto(Zona zona) {
        this.id = zona.getId();
        this.nome = zona.getNome();
        this.letra = zona.getLetra();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public String getLetra() { return letra; }
    public void setLetra(String letra) { this.letra = letra; }
}