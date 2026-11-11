function initPulseStreamerEnv()
% Inicializa el entorno Python para usar PulseStreamer desde MATLAB
% Configura pyenv, verifica e instala zmq, numpy y pulsestreamer

%% ----------------- CONFIGURACIÓN -----------------
minicondaPython = 'C:\Users\Giuseppe\miniconda3\python.exe';  % ruta a tu Python de Miniconda

%% ----------------- CONFIGURAR PYENV -----------------
try
    env = pyenv;
    if ~strcmp(env.Executable, minicondaPython) || env.ExecutionMode ~= "OutOfProcess"
        fprintf('⚙️ Configurando Python de Miniconda...\n');
        pyenv('ExecutionMode','OutOfProcess','Version',minicondaPython);
    else
        fprintf('✅ Python ya configurado correctamente.\n');
    end
catch
    fprintf('⚙️ Configurando Python de Miniconda...\n');
    pyenv('ExecutionMode','OutOfProcess','Version',minicondaPython);
end

env = pyenv;
fprintf('Python activo: %s\n', env.Executable);

%% ----------------- VERIFICAR / INSTALAR LIBRERÍAS -----------------
packages = {'zmq','numpy','pulsestreamer'};

for k = 1:length(packages)
    pkg = packages{k};
    try
        py.importlib.import_module(pkg);
        fprintf('✅ Paquete %s ya instalado.\n', pkg);
    catch
        fprintf('📦 Instalando %s...\n', pkg);
        cmd = sprintf('"%s" -m pip install %s', minicondaPython, pkg);
        [status, result] = system(cmd);
        if status == 0
            fprintf('✅ %s instalado correctamente.\n', pkg);
        else
            warning('❌ No se pudo instalar %s:\n%s', pkg, result);
        end
    end
end

fprintf('🎯 Entorno Python listo para PulseStreamer.\n');
end