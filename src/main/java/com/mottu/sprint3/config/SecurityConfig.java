package com.mottu.sprint3.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers("/css/**", "/js/**", "/images/**", "/webjars/**", "/favicon.ico").permitAll()
                .requestMatchers("/login", "/error").permitAll()
                // Rotas de criação e edição apenas para ADMIN
                .requestMatchers("/moto/save", "/patio/save", "/zona/save", "/status/save", "/status-grupo/save").hasRole("ADMIN")
                // Rotas de exclusão apenas para ADMIN
                .requestMatchers("/moto/delete/**", "/patio/delete/**", "/zona/delete/**", "/status/delete/**", "/status-grupo/delete/**").hasRole("ADMIN")
                // Rotas de movimentação de motos para ADMIN e OPERADOR
                .requestMatchers("/moto/move/**", "/moto/change-status/**").hasAnyRole("ADMIN", "OPERADOR")
                // Dashboard para todos os usuários autenticados
                .requestMatchers("/", "/dashboard").hasAnyRole("ADMIN", "OPERADOR", "USER")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login").permitAll()
                .defaultSuccessUrl("/", true)
                .failureUrl("/login?error=true")
            )
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout=true")
                .invalidateHttpSession(true)
                .clearAuthentication(true)
                .deleteCookies("JSESSIONID")
                .permitAll()
            )
            .csrf(csrf -> csrf.disable());
        
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}