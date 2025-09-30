package com.mottu.sprint3.controller;

import com.mottu.sprint3.model.Moto;
import com.mottu.sprint3.repository.MotoRepository;
import com.mottu.sprint3.repository.PatioRepository;
import com.mottu.sprint3.repository.StatusRepository;
import com.mottu.sprint3.repository.ZonaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

@Controller
public class MotoMovimentacaoController {

    @Autowired
    private MotoRepository motoRepository;

    @Autowired
    private ZonaRepository zonaRepository;

    @Autowired
    private PatioRepository patioRepository;

    @Autowired
    private StatusRepository statusRepository;

    // Fluxo 1: Movimentação de motos entre pátios/zonas
    @PostMapping("/moto/move")
    public String moverMoto(@RequestParam("motoId") Long motoId,
                          @RequestParam("novoPatioId") Long novoPatioId,
                          @RequestParam("novaZonaId") Long novaZonaId,
                          RedirectAttributes ra) {
        try {
            Optional<Moto> motoOpt = motoRepository.findById(motoId);
            if (!motoOpt.isPresent()) {
                ra.addFlashAttribute("mensagemErro", "Moto não encontrada!");
                return "redirect:/";
            }

            Moto moto = motoOpt.get();
            
            // Validação de negócio: não pode mover para o mesmo local
            if (moto.getPatio() != null && moto.getPatio().getId().equals(novoPatioId) &&
                moto.getZona() != null && moto.getZona().getId().equals(novaZonaId)) {
                ra.addFlashAttribute("mensagemErro", "A moto já está neste local!");
                return "redirect:/";
            }

            // Validação: moto deve ter status que permita movimentação
            if (moto.getStatus() != null && 
                (moto.getStatus().getNome().equals("Entregue") || 
                 moto.getStatus().getNome().equals("Em Reparo"))) {
                ra.addFlashAttribute("mensagemErro", "Não é possível mover motos com status '" + moto.getStatus().getNome() + "'!");
                return "redirect:/";
            }

            moto.setPatio(patioRepository.findById(novoPatioId).orElse(null));
            moto.setZona(zonaRepository.findById(novaZonaId).orElse(null));
            
            motoRepository.save(moto);
            ra.addFlashAttribute("mensagemSucesso", 
                "Moto " + moto.getIdentificacao() + " movida com sucesso para " + 
                moto.getPatio().getNome() + " - " + moto.getZona().getNome());

        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao mover a moto: " + e.getMessage());
        }
        return "redirect:/";
    }

    // Fluxo 2: Mudança de status com validações de negócio
    @PostMapping("/moto/change-status")
    public String alterarStatus(@RequestParam("motoId") Long motoId,
                                @RequestParam("novoStatusId") Long novoStatusId,
                                RedirectAttributes ra) {
        try {
            Optional<Moto> motoOpt = motoRepository.findById(motoId);
            if (!motoOpt.isPresent()) {
                ra.addFlashAttribute("mensagemErro", "Moto não encontrada!");
                return "redirect:/";
            }

            Moto moto = motoOpt.get();
            String statusAtual = moto.getStatus() != null ? moto.getStatus().getNome() : "Sem status";
            
            // Validação: não pode alterar para o mesmo status
            if (moto.getStatus() != null && moto.getStatus().getId().equals(novoStatusId)) {
                ra.addFlashAttribute("mensagemErro", "A moto já possui este status!");
                return "redirect:/";
            }

            // Validação de negócio: regras específicas de transição de status
            if (statusAtual.equals("Entregue")) {
                ra.addFlashAttribute("mensagemErro", "Não é possível alterar status de motos já entregues!");
                return "redirect:/";
            }

            // Validação: motos em reparo só podem ir para status específicos
            if (statusAtual.equals("Em Reparo")) {
                String novoStatusNome = statusRepository.findById(novoStatusId).orElse(null).getNome();
                if (!novoStatusNome.equals("Pronta para Entrega") && !novoStatusNome.equals("Necessita Reparo")) {
                    ra.addFlashAttribute("mensagemErro", "Motos em reparo só podem ir para 'Pronta para Entrega' ou 'Necessita Reparo'!");
                    return "redirect:/";
                }
            }

            moto.setStatus(statusRepository.findById(novoStatusId).orElse(null));
            motoRepository.save(moto);
            
            String novoStatusNome = moto.getStatus().getNome();
            ra.addFlashAttribute("mensagemSucesso", 
                "Status da moto " + moto.getIdentificacao() + " alterado de '" + statusAtual + "' para '" + novoStatusNome + "'");

        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao alterar status da moto: " + e.getMessage());
        }
        return "redirect:/";
    }
}
