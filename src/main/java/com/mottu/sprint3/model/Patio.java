package com.mottu.sprint3.model;

import jakarta.persistence.*;

@Entity
@Table(name = "patio")
public class Patio {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "patio_seq")
    @SequenceGenerator(name = "patio_seq", sequenceName = "patio_seq", allocationSize = 1)
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