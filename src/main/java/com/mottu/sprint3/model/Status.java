package com.mottu.sprint3.model;

import jakarta.persistence.*;

@Entity
@Table(name = "status")
public class Status {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;

    @ManyToOne
    @JoinColumn(name = "status_grupo_id")
    private StatusGrupo statusGrupo;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getNome() {
		return nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}

	public StatusGrupo getStatusGrupo() {
		return statusGrupo;
	}

	public void setStatusGrupo(StatusGrupo statusGrupo) {
		this.statusGrupo = statusGrupo;
	}

    
}