package com.mottu.sprint3.controller;

import com.mottu.sprint3.dto.MotoDto;
import com.mottu.sprint3.model.Moto;
import com.mottu.sprint3.repository.MotoRepository;
import com.mottu.sprint3.repository.PatioRepository;
import com.mottu.sprint3.repository.StatusRepository;
import com.mottu.sprint3.repository.ZonaRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Optional;

@Controller
public class MotoController {

    @Autowired
    private MotoRepository motoRepository;

    @Autowired
    private ZonaRepository zonaRepository;

    @Autowired
    private PatioRepository patioRepository;

    @Autowired
    private StatusRepository statusRepository;

    @PostMapping("/moto/save")
    public String saveMoto(@ModelAttribute("motoDto") @Valid MotoDto motoDto, 
                          BindingResult bindingResult, 
                          RedirectAttributes ra) {
        
        System.out.println("=== DADOS RECEBIDOS ===");
        System.out.println("ID: " + motoDto.getId());
        System.out.println("Placa: '" + motoDto.getPlaca() + "'");
        System.out.println("Chassi: '" + motoDto.getChassi() + "'");
        System.out.println("QR Code: '" + motoDto.getQrCode() + "'");
        System.out.println("ZonaId: " + motoDto.getZonaId());
        System.out.println("PatioId: " + motoDto.getPatioId());
        System.out.println("StatusId: " + motoDto.getStatusId());
        
        // Se houver erros de validação, retorna com as mensagens
        if (bindingResult.hasErrors()) {
            ra.addFlashAttribute("mensagemErro", "Erro de validação: " + bindingResult.getAllErrors().get(0).getDefaultMessage());
            return "redirect:/";
        }
        
        try {
            Moto moto = new Moto();
            
            // Se for uma edição, busca a moto existente
            if (motoDto.getId() != null && motoDto.getId() > 0) {
                System.out.println("=== EDITANDO MOTO COM ID: " + motoDto.getId() + " ===");
                Optional<Moto> existingMoto = motoRepository.findById(motoDto.getId());
                if (existingMoto.isPresent()) {
                    moto = existingMoto.get();
                    System.out.println("Moto encontrada para edição: " + moto.getId());
                } else {
                    System.out.println("ATENÇÃO: Moto com ID " + motoDto.getId() + " não encontrada!");
                }
            } else {
                System.out.println("=== CRIANDO NOVA MOTO ===");
            }

            // Mapeia os dados do DTO para a Model - tratando strings vazias como null
            moto.setPlaca(motoDto.getPlaca() != null && !motoDto.getPlaca().trim().isEmpty() ? motoDto.getPlaca().trim() : null);
            moto.setChassi(motoDto.getChassi() != null && !motoDto.getChassi().trim().isEmpty() ? motoDto.getChassi().trim() : null);
            moto.setQrCode(motoDto.getQrCode() != null && !motoDto.getQrCode().trim().isEmpty() ? motoDto.getQrCode().trim() : null);
            moto.setFotos(motoDto.getFotos() != null && !motoDto.getFotos().trim().isEmpty() ? motoDto.getFotos().trim() : null);
            moto.setObservacoes(motoDto.getObservacoes() != null && !motoDto.getObservacoes().trim().isEmpty() ? motoDto.getObservacoes().trim() : null);
            
            if (moto.getDataEntrada() == null) {
                moto.setDataEntrada(Timestamp.valueOf(LocalDateTime.now()));
            }
            
            moto.setPrevisaoEntrega(motoDto.getPrevisaoEntregaAsTimestamp());

            // Mapeamento dos relacionamentos com base nos IDs
            if (motoDto.getZonaId() != null) {
                moto.setZona(zonaRepository.findById(motoDto.getZonaId()).orElse(null));
            }
            if (motoDto.getPatioId() != null) {
                moto.setPatio(patioRepository.findById(motoDto.getPatioId()).orElse(null));
            }
            if (motoDto.getStatusId() != null) {
                moto.setStatus(statusRepository.findById(motoDto.getStatusId()).orElse(null));
            }

            System.out.println("=== ANTES DE SALVAR ===");
            System.out.println("Moto ID: " + moto.getId());
            System.out.println("Placa final: '" + moto.getPlaca() + "'");
            System.out.println("Chassi final: '" + moto.getChassi() + "'");
            System.out.println("QR Code final: '" + moto.getQrCode() + "'");

            // Salva a moto no banco de dados
            Moto savedMoto = motoRepository.save(moto);
            System.out.println("=== MOTO SALVA COM ID: " + savedMoto.getId() + " ===");
            
            if (motoDto.getId() != null && motoDto.getId() > 0) {
                ra.addFlashAttribute("mensagemSucesso", "Moto editada com sucesso!");
            } else {
                ra.addFlashAttribute("mensagemSucesso", "Moto adicionada com sucesso!");
            }
            
        } catch (Exception e) {
            System.err.println("=== ERRO AO SALVAR MOTO ===");
            e.printStackTrace();
            ra.addFlashAttribute("mensagemErro", "Erro ao salvar a moto: " + e.getMessage());
        }

        return "redirect:/"; // Redireciona para o dashboard
    }

    @GetMapping("/moto/delete/{id}")
    public String deleteMoto(@PathVariable("id") Long id, RedirectAttributes ra) {
        try {
            motoRepository.deleteById(id);
            ra.addFlashAttribute("mensagemSucesso", "Moto deletada com sucesso!");
        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao deletar a moto: " + e.getMessage());
        }
        return "redirect:/";
    }
}