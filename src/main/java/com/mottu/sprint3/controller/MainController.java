package com.mottu.sprint3.controller;

import com.mottu.sprint3.model.Moto;
import com.mottu.sprint3.model.Patio;
import com.mottu.sprint3.model.Status;
import com.mottu.sprint3.model.StatusGrupo;
import com.mottu.sprint3.model.Zona;
import com.mottu.sprint3.repository.MotoRepository;
import com.mottu.sprint3.repository.PatioRepository;
import com.mottu.sprint3.repository.StatusGrupoRepository;
import com.mottu.sprint3.repository.StatusRepository;
import com.mottu.sprint3.repository.ZonaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class MainController {

    @Autowired
    private MotoRepository motoRepository;

    @Autowired
    private PatioRepository patioRepository;

    @Autowired
    private ZonaRepository zonaRepository;

    @Autowired
    private StatusRepository statusRepository;

    @Autowired
    private StatusGrupoRepository statusGrupoRepository;

    @GetMapping("/")
    public String dashboard(Model model) {
        // Carrega todas as listas do banco de dados
        List<Moto> motos = motoRepository.findAll();
        List<Patio> patios = patioRepository.findAll();
        List<Zona> zonas = zonaRepository.findAll();
        List<Status> statusList = statusRepository.findAll();
        List<StatusGrupo> grupos = statusGrupoRepository.findAll();

        // Adiciona as listas ao modelo para que o Thymeleaf possa acessá-las
        model.addAttribute("motos", motos);
        model.addAttribute("patios", patios);
        model.addAttribute("zonas", zonas);
        model.addAttribute("statusList", statusList);
        model.addAttribute("grupos", grupos);

        return "dashboard";
    }
}