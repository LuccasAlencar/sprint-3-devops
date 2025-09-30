package com.mottu.sprint3.model;

import jakarta.persistence.*;

@Entity
@Table(name = "zona")
public class Zona {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "zona_seq")
    @SequenceGenerator(name = "zona_seq", sequenceName = "zona_seq", allocationSize = 1)
    private Long id;

    private String nome;
    private String letra;
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
	public String getLetra() {
		return letra;
	}
	public void setLetra(String letra) {
		this.letra = letra;
	}

    
}