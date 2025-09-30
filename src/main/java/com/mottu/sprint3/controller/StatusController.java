package com.mottu.sprint3.controller;

import com.mottu.sprint3.dto.StatusDto;
import com.mottu.sprint3.model.Status;
import com.mottu.sprint3.repository.StatusGrupoRepository;
import com.mottu.sprint3.repository.StatusRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.validation.BindingResult;

@Controller
public class StatusController {

    @Autowired
    private StatusRepository statusRepository;
    @Autowired
    private StatusGrupoRepository statusGrupoRepository;

    @PostMapping("/status/save")
    public String saveStatus(@ModelAttribute("statusDto") @Valid StatusDto statusDto, 
                            BindingResult bindingResult,
                            RedirectAttributes ra) {
        
        if (bindingResult.hasErrors()) {
            ra.addFlashAttribute("mensagemErro", "Erro de validação: " + bindingResult.getAllErrors().get(0).getDefaultMessage());
            return "redirect:/";
        }
        
        try {
            Status status = statusDto.getId() != null ? statusRepository.findById(statusDto.getId()).orElse(new Status()) : new Status();
            status.setNome(statusDto.getNome());
            if (statusDto.getStatusGrupoId() != null) {
                status.setStatusGrupo(statusGrupoRepository.findById(statusDto.getStatusGrupoId()).orElse(null));
            }
            statusRepository.save(status);
            ra.addFlashAttribute("mensagemSucesso", "Status salvo com sucesso!");
        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao salvar o status: " + e.getMessage());
        }
        return "redirect:/";
    }

    @GetMapping("/status/delete/{id}")
    public String deleteStatus(@PathVariable("id") Long id, RedirectAttributes ra) {
        try {
            statusRepository.deleteById(id);
            ra.addFlashAttribute("mensagemSucesso", "Status deletado com sucesso!");
        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao deletar o status: " + e.getMessage());
        }
        return "redirect:/";
    }
}