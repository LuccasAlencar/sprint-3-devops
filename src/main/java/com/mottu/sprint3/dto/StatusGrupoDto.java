package com.mottu.sprint3.dto;

import com.mottu.sprint3.model.StatusGrupo;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class StatusGrupoDto {
    private Long id;
    
    @NotBlank(message = "Nome do grupo é obrigatório")
    @Size(min = 2, max = 100, message = "Nome deve ter entre 2 e 100 caracteres")
    private String nome;

    public StatusGrupoDto() {}

    public StatusGrupoDto(StatusGrupo statusGrupo) {
        this.id = statusGrupo.getId();
        this.nome = statusGrupo.getNome();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
}