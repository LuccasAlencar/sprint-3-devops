package com.mottu.sprint3.dto;

import com.mottu.sprint3.model.Status;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class StatusDto {
    private Long id;
    
    @NotBlank(message = "Nome do status é obrigatório")
    @Size(min = 2, max = 100, message = "Nome deve ter entre 2 e 100 caracteres")
    private String nome;
    
    @NotNull(message = "Grupo de status é obrigatório")
    private Long statusGrupoId;

    public StatusDto() {}

    public StatusDto(Status status) {
        this.id = status.getId();
        this.nome = status.getNome();
        if (status.getStatusGrupo() != null) {
            this.statusGrupoId = status.getStatusGrupo().getId();
        }
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public Long getStatusGrupoId() { return statusGrupoId; }
    public void setStatusGrupoId(Long statusGrupoId) { this.statusGrupoId = statusGrupoId; }
}