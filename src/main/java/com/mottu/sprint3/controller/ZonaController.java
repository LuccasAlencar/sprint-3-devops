package com.mottu.sprint3.controller;

import com.mottu.sprint3.dto.ZonaDto;
import com.mottu.sprint3.model.Zona;
import com.mottu.sprint3.repository.ZonaRepository;
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
public class ZonaController {

    @Autowired
    private ZonaRepository zonaRepository;

    @PostMapping("/zona/save")
    public String saveZona(@ModelAttribute("zonaDto") @Valid ZonaDto zonaDto, 
                          BindingResult bindingResult,
                          RedirectAttributes ra) {
        
        if (bindingResult.hasErrors()) {
            ra.addFlashAttribute("mensagemErro", "Erro de validação: " + bindingResult.getAllErrors().get(0).getDefaultMessage());
            return "redirect:/";
        }
        
        try {
            Zona zona = zonaDto.getId() != null ? zonaRepository.findById(zonaDto.getId()).orElse(new Zona()) : new Zona();
            zona.setNome(zonaDto.getNome());
            zona.setLetra(zonaDto.getLetra());
            zonaRepository.save(zona);
            ra.addFlashAttribute("mensagemSucesso", "Zona salva com sucesso!");
        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao salvar a zona: " + e.getMessage());
        }
        return "redirect:/";
    }

    @GetMapping("/zona/delete/{id}")
    public String deleteZona(@PathVariable("id") Long id, RedirectAttributes ra) {
        try {
            zonaRepository.deleteById(id);
            ra.addFlashAttribute("mensagemSucesso", "Zona deletada com sucesso!");
        } catch (Exception e) {
            ra.addFlashAttribute("mensagemErro", "Erro ao deletar a zona: " + e.getMessage());
        }
        return "redirect:/";
    }
}