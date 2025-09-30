package com.mottu.sprint3.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        Object status = request.getAttribute("jakarta.servlet.error.status_code");
        Object exception = request.getAttribute("jakarta.servlet.error.exception");
        Object message = request.getAttribute("jakarta.servlet.error.message");

        if (status != null) {
            Integer statusCode = Integer.valueOf(status.toString());
            
            if (statusCode == 404) {
                model.addAttribute("errorTitle", "Página não encontrada");
                model.addAttribute("errorMessage", "A página que você está procurando não existe.");
            } else if (statusCode == 400) {
                model.addAttribute("errorTitle", "Erro de validação");
                model.addAttribute("errorMessage", "Os dados fornecidos são inválidos. Verifique os campos obrigatórios.");
            } else if (statusCode == 500) {
                model.addAttribute("errorTitle", "Erro interno do servidor");
                model.addAttribute("errorMessage", "Ocorreu um erro interno. Tente novamente em alguns instantes.");
            } else {
                model.addAttribute("errorTitle", "Erro " + statusCode);
                model.addAttribute("errorMessage", message != null ? message.toString() : "Ocorreu um erro inesperado.");
            }
        } else {
            model.addAttribute("errorTitle", "Erro inesperado");
            model.addAttribute("errorMessage", "Ocorreu um erro inesperado. Tente novamente.");
        }

        return "error";
    }
}