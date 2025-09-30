package com.mottu.sprint3.controller;

import com.mottu.sprint3.dto.StatusGrupoDto;
import com.mottu.sprint3.model.StatusGrupo;
import com.mottu.sprint3.repository.StatusGrupoRepository;
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
public class StatusGrupoController {

    @Autowired
    private StatusGrupoRepository statusGrupoRepository;

    @PostMapping("/status-grupo/save")
    public String saveStatusGrupo(@ModelAttribute("statusGrupoDto") @Valid StatusGrupoDto statusGrupoDto, 
                                  BindingResult bindingResult,
                                  RedirectAttributes ra) {
        
        if (bindingResult.hasErrors()) {
            ra.addFlashAttribute("mensagemErro", "Erro de validação: " + bindingResult.getAllErrors().get(0).getDefaultMessage());
            return "redirect:/";
        }
        
        try {
            StatusGrupo statusGrupo = statusGrupoDto.getId() != null ? statusGrupoRepository.findById(statusGrupoDto.getId()).orElse(new StatusGrupo()) : new StatusGrupo();
            statusGrupo.setNome(statusGrupoDto.getNome());
            statusGrupoRepository.save(statusGrupo);
            ra.addFlashAttribute("mensagemSucesso", "Grupo de status salvo com sucesso!");
        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao salvar o grupo de status: " + e.getMessage());
        }
        return "redirect:/";
    }

    @GetMapping("/status-grupo/delete/{id}")
    public String deleteStatusGrupo(@PathVariable("id") Long id, RedirectAttributes ra) {
        try {
            statusGrupoRepository.deleteById(id);
            ra.addFlashAttribute("mensagemSucesso", "Grupo de status deletado com sucesso!");
        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao deletar o grupo de status: " + e.getMessage());
        }
        return "redirect:/";
    }
}