% RENOMBRARPANEL  Crea copias renombradas de PanelOwis (.m y .fig) y de
% RingDetection, sin tocar los originales.
%
% Cómo usarlo:
%   1) Pon este archivo en la carpeta NUEVA (donde están PanelOwis.m,
%      PanelOwis.fig y RingDetection.m modificados).
%   2) Cambia abajo los nombres si quieres otros (sin espacios ni acentos,
%      deben empezar con letra).
%   3) Estando en esa carpeta, escribe en la consola:  renombrarPanel
%
% Resultado: nuevoPanel.m, nuevoPanel.fig y nuevoRing.m listos para usar.

nuevoPanel = 'PanelOwisCirculos';
nuevoRing  = 'RingDetectionCirc';

viejoPanel = 'PanelOwis';
viejoRing  = 'RingDetection';

% ---------- comprobar que estamos en la carpeta correcta ----------
req = {[viejoPanel '.m'], [viejoPanel '.fig'], [viejoRing '.m']};
for k = 1:numel(req)
    if ~isfile(fullfile(pwd, req{k}))
        error('No encuentro %s en la carpeta actual (%s).', req{k}, pwd);
    end
end
txt = leer(fullfile(pwd, [viejoPanel '.m']));
if ~contains(txt, 'circlesMov')
    error(['El PanelOwis.m de esta carpeta NO es la versión de círculos. ' ...
           'Revisa que estés en la carpeta nueva.']);
end

% ---------- 1) RingDetection -> nuevoRing ----------
txt = leer(fullfile(pwd, [viejoRing '.m']));
txt = regexprep(txt, ['\<' viejoRing '\>'], nuevoRing);
escribir(fullfile(pwd, [nuevoRing '.m']), txt);

% ---------- 2) PanelOwis.m -> nuevoPanel.m ----------
txt = leer(fullfile(pwd, [viejoPanel '.m']));
txt = regexprep(txt, ['\<' viejoRing '\>'], nuevoRing);            % llamadas a la detección
txt = regexprep(txt, [viejoPanel '(?=_OpeningFcn|_OutputFcn)'], nuevoPanel);
txt = regexprep(txt, ['^function varargout = ' viejoPanel '\('], ...
                     ['function varargout = ' nuevoPanel '('], 'lineanchors');
escribir(fullfile(pwd, [nuevoPanel '.m']), txt);

% ---------- 3) PanelOwis.fig -> nuevoPanel.fig ----------
% Cada botón del .fig guarda el nombre del archivo en su callback, por
% ejemplo  PanelOwis('pushbutton7_Callback',...).  Se cambian todos.
fig = openfig(fullfile(pwd, [viejoPanel '.fig']), 'new', 'invisible');
props = {'Callback','CreateFcn','DeleteFcn','ButtonDownFcn','KeyPressFcn', ...
         'KeyReleaseFcn','CloseRequestFcn','ResizeFcn','SizeChangedFcn', ...
         'WindowButtonDownFcn','WindowButtonUpFcn','WindowButtonMotionFcn', ...
         'WindowKeyPressFcn','WindowScrollWheelFcn','SelectionChangedFcn', ...
         'CellEditCallback','CellSelectionCallback'};
nCambios = 0;
objs = findall(fig);
for i = 1:numel(objs)
    for j = 1:numel(props)
        if ~isprop(objs(i), props{j}), continue; end
        cb = get(objs(i), props{j});
        if ischar(cb) && contains(cb, viejoPanel)
            set(objs(i), props{j}, strrep(cb, [viejoPanel '('], [nuevoPanel '(']));
            nCambios = nCambios + 1;
        elseif isa(cb, 'function_handle')
            s = func2str(cb);
            if contains(s, [viejoPanel '('])
                if s(1) ~= '@', s = ['@' s]; end
                set(objs(i), props{j}, str2func(strrep(s, [viejoPanel '('], [nuevoPanel '('])));
                nCambios = nCambios + 1;
            end
        end
    end
end
if strcmp(get(fig,'Name'), viejoPanel), set(fig, 'Name', nuevoPanel); end
savefig(fig, fullfile(pwd, [nuevoPanel '.fig']));
delete(fig);

rehash
fprintf('\nListo. Se cambiaron %d callbacks en el .fig.\n', nCambios);
fprintf('Creados: %s.m, %s.fig y %s.m\n', nuevoPanel, nuevoPanel, nuevoRing);
fprintf('Ábrelo con:  %s\n', nuevoPanel);

% -------------------------------------------------------------------------
function txt = leer(ruta)
fid = fopen(ruta, 'r', 'n', 'UTF-8');
if fid < 0, error('No pude leer %s', ruta); end
txt = fread(fid, '*char')';
fclose(fid);
end

function escribir(ruta, txt)
fid = fopen(ruta, 'w', 'n', 'UTF-8');
if fid < 0, error('No pude escribir %s', ruta); end
fprintf(fid, '%s', txt);
fclose(fid);
end
