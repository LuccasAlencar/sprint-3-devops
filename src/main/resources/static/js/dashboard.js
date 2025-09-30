console.log('Dashboard.js carregado com sucesso!');

document.addEventListener("DOMContentLoaded", function() {
    console.log('DOMContentLoaded executado!');
    
    // Função auxiliar para definir valor de campo de forma segura
    const setFieldValue = (fieldId, value) => {
        const field = document.getElementById(fieldId);
        if (field) {
            field.value = value || '';
            console.log(`Campo ${fieldId} definido como: "${value}"`);
        } else {
            console.error(`Campo ${fieldId} não encontrado!`);
        }
    };
    
    // === MODAL DE MOTO ===
    const motoModal = document.getElementById('motoModal');
    if (motoModal) {
        motoModal.addEventListener('show.bs.modal', function (event) {
            const button = event.relatedTarget;
            const action = button.getAttribute('data-action');
            const modalTitle = motoModal.querySelector('.modal-title');
            const form = document.getElementById('motoForm');

            console.log('Modal moto aberto - ação:', action);

            if (form) form.reset();

            if (action === 'add') {
                modalTitle.textContent = 'Adicionar Nova Moto';
                setFieldValue('motoId', '');
            } else if (action === 'edit') {
                modalTitle.textContent = 'Editar Moto';
                const row = button.closest('tr');
                
                const motoId = row.getAttribute('data-moto-id');
                const placa = row.getAttribute('data-moto-placa');
                const chassi = row.getAttribute('data-moto-chassi');
                const qrCode = row.getAttribute('data-moto-qrcode');
                const previsaoEntrega = row.getAttribute('data-moto-previsao-entrega');
                const observacoes = row.getAttribute('data-moto-observacoes');
                const zonaId = row.getAttribute('data-moto-zona-id');
                const patioId = row.getAttribute('data-moto-patio-id');
                const statusId = row.getAttribute('data-moto-status-id');

                setFieldValue('motoId', motoId);
                setFieldValue('placa', placa === 'null' ? '' : placa);
                setFieldValue('chassi', chassi === 'null' ? '' : chassi);
                setFieldValue('qrCode', qrCode === 'null' ? '' : qrCode);
                setFieldValue('observacoes', observacoes === 'null' ? '' : observacoes);
                setFieldValue('zonaId', zonaId);
                setFieldValue('patioId', patioId);
                setFieldValue('statusId', statusId);

                // Tratamento especial para data
                if (previsaoEntrega && previsaoEntrega !== 'null') {
                    try {
                        const date = new Date(previsaoEntrega);
                        if (!isNaN(date.getTime())) {
                            const formattedDate = date.toISOString().slice(0, 10);
                            setFieldValue('previsaoEntrega', formattedDate);
                        }
                    } catch (e) {
                        console.warn('Erro ao formatar data:', e);
                    }
                }
            }
        });
    }

    // === MODAL DE PÁTIO - CORRIGIDO ===
    const patioModal = document.getElementById('patioModal');
    if (patioModal) {
        patioModal.addEventListener('show.bs.modal', function (event) {
            const button = event.relatedTarget;
            const action = button.getAttribute('data-action');
            const modalTitle = patioModal.querySelector('.modal-title');
            const form = document.getElementById('patioForm');

            console.log('Modal patio aberto - ação:', action);

            if (form) form.reset();

            if (action === 'add') {
                modalTitle.textContent = 'Adicionar Novo Pátio';
                setFieldValue('patioIdHidden', ''); // ID CORRIGIDO
            } else if (action === 'edit') {
                modalTitle.textContent = 'Editar Pátio';
                const row = button.closest('tr');
                
                const patioId = row.getAttribute('data-patio-id');
                const patioNome = row.getAttribute('data-patio-nome');
                
                setFieldValue('patioIdHidden', patioId); // ID CORRIGIDO
                setFieldValue('patioNomeInput', patioNome); // ID CORRIGIDO
                
                console.log('Pátio - ID definido:', patioId, 'Nome:', patioNome);
            }
        });
    }

    // === MODAL DE ZONA - CORRIGIDO ===
    const zonaModal = document.getElementById('zonaModal');
    if (zonaModal) {
        zonaModal.addEventListener('show.bs.modal', function (event) {
            const button = event.relatedTarget;
            const action = button.getAttribute('data-action');
            const modalTitle = zonaModal.querySelector('.modal-title');
            const form = document.getElementById('zonaForm');

            console.log('Modal zona aberto - ação:', action);

            if (form) form.reset();

            if (action === 'add') {
                modalTitle.textContent = 'Adicionar Nova Zona';
                setFieldValue('zonaIdHidden', ''); // ID CORRIGIDO
            } else if (action === 'edit') {
                modalTitle.textContent = 'Editar Zona';
                const row = button.closest('tr');
                
                const zonaId = row.getAttribute('data-zona-id');
                const zonaNome = row.getAttribute('data-zona-nome');
                const zonaLetra = row.getAttribute('data-zona-letra');
                
                setFieldValue('zonaIdHidden', zonaId); // ID CORRIGIDO
                setFieldValue('zonaNomeInput', zonaNome); // ID CORRIGIDO
                setFieldValue('zonaLetraInput', zonaLetra); // ID CORRIGIDO
                
                console.log('Zona - ID definido:', zonaId, 'Nome:', zonaNome, 'Letra:', zonaLetra);
            }
        });
    }

    // === MODAL DE STATUS - CORRIGIDO ===
    const statusModal = document.getElementById('statusModal');
    if (statusModal) {
        statusModal.addEventListener('show.bs.modal', function (event) {
            const button = event.relatedTarget;
            const action = button.getAttribute('data-action');
            const modalTitle = statusModal.querySelector('.modal-title');
            const form = document.getElementById('statusForm');

            console.log('Modal status aberto - ação:', action);

            if (form) form.reset();

            if (action === 'add') {
                modalTitle.textContent = 'Adicionar Novo Status';
                setFieldValue('statusIdHidden', ''); // ID CORRIGIDO
            } else if (action === 'edit') {
                modalTitle.textContent = 'Editar Status';
                const row = button.closest('tr');
                
                const statusId = row.getAttribute('data-status-id');
                const statusNome = row.getAttribute('data-status-nome');
                const statusGrupoId = row.getAttribute('data-status-grupo-id');
                
                setFieldValue('statusIdHidden', statusId); // ID CORRIGIDO
                setFieldValue('statusNomeInput', statusNome); // ID CORRIGIDO
                setFieldValue('statusGrupoSelect', statusGrupoId); // ID CORRIGIDO
                
                console.log('Status - ID definido:', statusId, 'Nome:', statusNome, 'Grupo:', statusGrupoId);
            }
        });
    }

    // === MODAL DE STATUS GRUPO - CORRIGIDO ===
    const statusGrupoModal = document.getElementById('statusGrupoModal');
    if (statusGrupoModal) {
        statusGrupoModal.addEventListener('show.bs.modal', function (event) {
            const button = event.relatedTarget;
            const action = button.getAttribute('data-action');
            const modalTitle = statusGrupoModal.querySelector('.modal-title');
            const form = document.getElementById('statusGrupoForm');

            console.log('Modal status grupo aberto - ação:', action);

            if (form) form.reset();

            if (action === 'add') {
                modalTitle.textContent = 'Adicionar Novo Grupo de Status';
                setFieldValue('statusGrupoIdHidden', ''); // ID CORRIGIDO
            } else if (action === 'edit') {
                modalTitle.textContent = 'Editar Grupo de Status';
                const row = button.closest('tr');
                
                const statusGrupoId = row.getAttribute('data-grupo-id');
                const statusGrupoNome = row.getAttribute('data-grupo-nome');
                
                setFieldValue('statusGrupoIdHidden', statusGrupoId); // ID CORRIGIDO
                setFieldValue('statusGrupoNomeInput', statusGrupoNome); // ID CORRIGIDO
                
                console.log('StatusGrupo - ID definido:', statusGrupoId, 'Nome:', statusGrupoNome);
            }
        });
    }

    // === MODAL DE MOVIMENTAÇÃO DE MOTO ===
    const moverMotoModal = document.getElementById('moverMotoModal');
    if (moverMotoModal) {
        moverMotoModal.addEventListener('show.bs.modal', function (event) {
            const button = event.relatedTarget;
            const motoId = button.getAttribute('data-moto-id');
            const form = document.getElementById('moverMotoForm');

            console.log('Modal mover moto aberto - motoId:', motoId);

            if (form) form.reset();
            setFieldValue('motoIdMove', motoId);
        });
    }

    // === MODAL DE ALTERAÇÃO DE STATUS ===
    const alterarStatusModal = document.getElementById('alterarStatusModal');
    if (alterarStatusModal) {
        alterarStatusModal.addEventListener('show.bs.modal', function (event) {
            const button = event.relatedTarget;
            const motoId = button.getAttribute('data-moto-id');
            const form = document.getElementById('alterarStatusForm');

            console.log('Modal alterar status aberto - motoId:', motoId);

            if (form) form.reset();
            setFieldValue('motoIdStatus', motoId);
        });
    }

    // === CONFIRMAÇÃO PARA BOTÕES DE EXCLUSÃO ===
    const deleteButtons = document.querySelectorAll('.delete-btn');
    console.log('Botões de exclusão encontrados:', deleteButtons.length);
    
    deleteButtons.forEach(button => {
        button.addEventListener('click', function(event) {
            if (!confirm('Tem certeza que deseja excluir este item?')) {
                event.preventDefault();
            }
        });
    });

    // === VALIDAÇÃO E FEEDBACK PARA FORMULÁRIOS ===
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function(event) {
            // Log dos dados que estão sendo enviados
            const formData = new FormData(form);
            console.log('=== ENVIANDO FORMULÁRIO ===');
            console.log('Form ID:', form.id);
            for (let [key, value] of formData.entries()) {
                console.log(`${key}: ${value}`);
            }

            // Validação específica para o formulário de moto
            if (form.id === 'motoForm') {
                const placa = document.getElementById('placa').value.trim();
                const chassi = document.getElementById('chassi').value.trim();
                const qrCode = document.getElementById('qrCode').value.trim();
                
                if (!placa && !chassi && !qrCode) {
                    event.preventDefault();
                    alert('Preencha pelo menos um dos campos: Placa, Chassi ou QR Code');
                    return;
                }
            }
            
            // Feedback visual no botão de submit
            const submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn) {
                const originalText = submitBtn.innerHTML;
                submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Salvando...';
                submitBtn.disabled = true;
                
                // Restaura o botão se houver erro
                setTimeout(() => {
                    submitBtn.innerHTML = originalText;
                    submitBtn.disabled = false;
                }, 5000);
            }
        });
    });

    // === DEBUG: Verificar se os elementos existem ===
    console.log('=== VERIFICAÇÃO DOS ELEMENTOS ===');
    console.log('Modal Pátio:', document.getElementById('patioModal') ? 'OK' : 'NÃO ENCONTRADO');
    console.log('Campo patioIdHidden:', document.getElementById('patioIdHidden') ? 'OK' : 'NÃO ENCONTRADO');
    console.log('Campo patioNomeInput:', document.getElementById('patioNomeInput') ? 'OK' : 'NÃO ENCONTRADO');
    
    console.log('Modal Zona:', document.getElementById('zonaModal') ? 'OK' : 'NÃO ENCONTRADO');
    console.log('Campo zonaIdHidden:', document.getElementById('zonaIdHidden') ? 'OK' : 'NÃO ENCONTRADO');
    console.log('Campo zonaNomeInput:', document.getElementById('zonaNomeInput') ? 'OK' : 'NÃO ENCONTRADO');
    
    console.log('Modal Status:', document.getElementById('statusModal') ? 'OK' : 'NÃO ENCONTRADO');
    console.log('Campo statusIdHidden:', document.getElementById('statusIdHidden') ? 'OK' : 'NÃO ENCONTRADO');
    console.log('Campo statusNomeInput:', document.getElementById('statusNomeInput') ? 'OK' : 'NÃO ENCONTRADO');
    
    console.log('Modal StatusGrupo:', document.getElementById('statusGrupoModal') ? 'OK' : 'NÃO ENCONTRADO');
    console.log('Campo statusGrupoIdHidden:', document.getElementById('statusGrupoIdHidden') ? 'OK' : 'NÃO ENCONTRADO');
    console.log('Campo statusGrupoNomeInput:', document.getElementById('statusGrupoNomeInput') ? 'OK' : 'NÃO ENCONTRADO');
});

// Função de debug para testar manualmente
window.debugModal = function(modalType) {
    const button = event.target;
    const row = button.closest('tr');
    console.log('=== DEBUG MODAL ===');
    console.log('Tipo:', modalType);
    console.log('Botão:', button);
    console.log('Linha:', row);
    console.log('Atributos da linha:', row.attributes);
    for (let attr of row.attributes) {
        console.log(`${attr.name}: ${attr.value}`);
    }
};