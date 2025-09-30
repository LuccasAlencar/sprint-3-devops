package com.mottu.sprint3.model;

import jakarta.persistence.*;

@Entity
@Table(name = "status_grupo")
public class StatusGrupo {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "status_grupo_seq")
    @SequenceGenerator(name = "status_grupo_seq", sequenceName = "status_grupo_seq", allocationSize = 1)
    private Long id;

    private String nome;

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

    
}