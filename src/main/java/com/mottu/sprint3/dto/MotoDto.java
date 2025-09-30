package com.mottu.sprint3.dto;

import com.mottu.sprint3.model.Moto;
import jakarta.validation.constraints.AssertTrue;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.sql.Timestamp;

public class MotoDto {

    private Long id;
    private String placa;
    private String chassi;
    private String qrCode;
    private Timestamp dataEntrada;
    
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate previsaoEntrega;
    
    private String fotos;
    private String observacoes;
    private Long zonaId;
    private Long patioId;
    private Long statusId;

    // Pelo menos um dos três campos deve estar preenchido
    @AssertTrue(message = "Pelo menos um dos campos (placa, chassi ou QR Code) deve estar preenchido")
    public boolean isAtLeastOneFieldFilled() {
        boolean placaOk = placa != null && !placa.trim().isEmpty();
        boolean chassiOk = chassi != null && !chassi.trim().isEmpty();
        boolean qrCodeOk = qrCode != null && !qrCode.trim().isEmpty();
        
        boolean resultado = placaOk || chassiOk || qrCodeOk;
        
        System.out.println("=== VALIDAÇÃO DOS CAMPOS ===");
        System.out.println("Placa OK: " + placaOk + " ('" + placa + "')");
        System.out.println("Chassi OK: " + chassiOk + " ('" + chassi + "')");
        System.out.println("QR Code OK: " + qrCodeOk + " ('" + qrCode + "')");
        System.out.println("Resultado da validação: " + resultado);
        
        return resultado;
    }

    // Construtor para facilitar a conversão de Model para DTO
    public MotoDto(Moto moto) {
        this.id = moto.getId();
        this.placa = moto.getPlaca();
        this.chassi = moto.getChassi();
        this.qrCode = moto.getQrCode();
        this.dataEntrada = moto.getDataEntrada();
        
        // Conversão de Timestamp para LocalDate
        if (moto.getPrevisaoEntrega() != null) {
            this.previsaoEntrega = moto.getPrevisaoEntrega().toLocalDateTime().toLocalDate();
        }
        
        this.fotos = moto.getFotos();
        this.observacoes = moto.getObservacoes();
        if (moto.getZona() != null) {
            this.zonaId = moto.getZona().getId();
        }
        if (moto.getPatio() != null) {
            this.patioId = moto.getPatio().getId();
        }
        if (moto.getStatus() != null) {
            this.statusId = moto.getStatus().getId();
        }
    }

    public MotoDto() {
    }

    // Método para converter LocalDate para Timestamp
    public Timestamp getPrevisaoEntregaAsTimestamp() {
        if (previsaoEntrega != null) {
            return Timestamp.valueOf(previsaoEntrega.atStartOfDay());
        }
        return null;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPlaca() {
        return placa;
    }

    public void setPlaca(String placa) {
        this.placa = placa;
    }

    public String getChassi() {
        return chassi;
    }

    public void setChassi(String chassi) {
        this.chassi = chassi;
    }

    public String getQrCode() {
        return qrCode;
    }

    public void setQrCode(String qrCode) {
        this.qrCode = qrCode;
    }

    public Timestamp getDataEntrada() {
        return dataEntrada;
    }

    public void setDataEntrada(Timestamp dataEntrada) {
        this.dataEntrada = dataEntrada;
    }

    public LocalDate getPrevisaoEntrega() {
        return previsaoEntrega;
    }

    public void setPrevisaoEntrega(LocalDate previsaoEntrega) {
        this.previsaoEntrega = previsaoEntrega;
    }

    public String getFotos() {
        return fotos;
    }

    public void setFotos(String fotos) {
        this.fotos = fotos;
    }

    public String getObservacoes() {
        return observacoes;
    }

    public void setObservacoes(String observacoes) {
        this.observacoes = observacoes;
    }

    public Long getZonaId() {
        return zonaId;
    }

    public void setZonaId(Long zonaId) {
        this.zonaId = zonaId;
    }

    public Long getPatioId() {
        return patioId;
    }

    public void setPatioId(Long patioId) {
        this.patioId = patioId;
    }

    public Long getStatusId() {
        return statusId;
    }

    public void setStatusId(Long statusId) {
        this.statusId = statusId;
    }
}