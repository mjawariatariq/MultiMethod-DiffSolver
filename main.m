classdef main < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        HeaderPanel                 matlab.ui.container.Panel
        ODESolverLabel              matlab.ui.control.Label
        EnterDifferentialEquationLabel matlab.ui.control.Label
        txtEquation                 matlab.ui.control.EditField
        SelectMethodLabel           matlab.ui.control.Label
        ddlMethod                   matlab.ui.control.DropDown
        btnSolve                    matlab.ui.control.Button
        btnHelp                     matlab.ui.control.Button
        btnClear                    matlab.ui.control.Button
        btnPDF                      matlab.ui.control.Button
        SolutionLabel               matlab.ui.control.Label
        txtSolution                 matlab.ui.control.TextArea
        UIAxes                      matlab.ui.control.UIAxes
    end

    % Callbacks that handle component events
    methods (Access = private)

        % 1. RK4 Numerical Solver Algorithm
        function [x, y] = rk4Solver(~, f, x0, y0, xEnd, steps)
            h = (xEnd - x0) / steps;
            x = zeros(steps + 1, 1);
            y = zeros(steps + 1, 1);
            x(1) = x0;
            y(1) = y0;
            for i = 1:steps
                xi = x(i);
                yi = y(i);
                k1 = f(xi, yi);
                k2 = f(xi + h/2, yi + h*k1/2);
                k3 = f(xi + h/2, yi + h*k2/2);
                k4 = f(xi + h, yi + h*k3);
                y(i+1) = yi + (h/6)*(k1 + 2*k2 + 2*k3 + k4);
                x(i+1) = xi + h;
            end
        end

        % 2. Ordinary Differential Equation (Euler Method Solver)
        function [x, y] = odeEulerSolver(~, f, x0, y0, xEnd, steps)
            h = (xEnd - x0) / steps;
            x = zeros(steps + 1, 1);
            y = zeros(steps + 1, 1);
            x(1) = x0;
            y(1) = y0;
            for i = 1:steps
                x(i+1) = x(i) + h;
                y(i+1) = y(i) + h * f(x(i), y(i));
            end
        end

        % Button pushed function: btnSolve
        function btnSolveButtonPushed(app, ~)
            try
                eqnStr = strtrim(app.txtEquation.Value);
                selectedMethod = app.ddlMethod.Value;
                if strcmp(selectedMethod, 'Differential Equation')
                    % Robust Symbolic Solution with str2sym
                    eqnClean = eqnStr;
                    eqnClean = strrep(eqnClean, 'diff(y,x)', 'diff(y(x),x)');
                    eqnClean = strrep(eqnClean, 'dy/dx', 'diff(y(x),x)');
                    if ~contains(eqnClean, 'y(x)') && contains(eqnClean, 'y')
                        eqnClean = strrep(eqnClean, 'y', 'y(x)');
                    end
                    if ~contains(eqnClean, '==') && contains(eqnClean, '=')
                        eqnClean = strrep(eqnClean, '=', '==');
                    end
                    odeSym = str2sym(eqnClean);
                    sol = dsolve(odeSym);
                    app.txtSolution.Value = {['Symbolic Solution:']; ['y(x) = ' char(sol)]};

                    % Plotting symbolic solution safely
                    try
                        syms C1 C2
                        solPlot = subs(sol, [C1 C2], [1 1]);
                        fplot(app.UIAxes, solPlot, [0, 5], 'LineWidth', 2, 'Color', [0 0.45 0.74]);
                        grid(app.UIAxes, 'on');
                        title(app.UIAxes, 'Symbolic Plot (C1=1)', 'FontSize', 11, 'FontWeight', 'bold');
                        xlabel(app.UIAxes, 'x');
                        ylabel(app.UIAxes, 'y(x)');
                    catch
                        cla(app.UIAxes);
                        title(app.UIAxes, 'Symbolic Solution (No Plot)');
                    end
                else
                    % Numerical Solvers (RK4 & Ordinary Differential Equation)
                    syms x y
                    eqnClean = eqnStr;
                    eqnClean = strrep(eqnClean, 'dy/dx', 'dydx');
                    if contains(eqnClean, '=')
                        parts = split(eqnClean, '=');
                        rhs = strtrim(parts{end});
                    else
                        rhs = eqnClean;
                    end
                    f = matlabFunction(str2sym(rhs), 'Vars', [x, y]);
                    if strcmp(selectedMethod, 'RK4')
                        [xSol, ySol] = app.rk4Solver(f, 0, 1, 5, 50);
                    else % Ordinary Differential Equation (Euler)
                        [xSol, ySol] = app.odeEulerSolver(f, 0, 1, 5, 50);
                    end
                    % Format solution output
                    solText = cell(length(xSol), 1);
                    for i = 1:length(xSol)
                        solText{i} = sprintf('x = %.2f   y = %.6f', xSol(i), ySol(i));
                    end
                    app.txtSolution.Value = solText;
                    % Plot numerical curve
                    plot(app.UIAxes, xSol, ySol, '-o', 'LineWidth', 1.8, 'Color', [0.07 0.45 0.87], ...
                        'MarkerFaceColor', [0.07 0.45 0.87], 'MarkerSize', 4);
                    grid(app.UIAxes, 'on');
                    title(app.UIAxes, [selectedMethod ' Solution Plot'], 'FontSize', 11, 'FontWeight', 'bold');
                    xlabel(app.UIAxes, 'x');
                    ylabel(app.UIAxes, 'y');
                end
            catch ME
                app.txtSolution.Value = {['Error: ' ME.message]};
            end
        end

        % Button pushed function: btnHelp
        function btnHelpButtonPushed(app, ~)
            msg = sprintf(['ODE Solver Usage Guide & Examples\n\n' ...
                '1. Differential Equation (Symbolic):\n' ...
                '   - Example A: diff(y(x),x) == y(x)\n' ...
                '   - Example B: diff(y(x),x) == x + y(x)\n' ...
                '   - Example C: dy/dx == cos(x)\n\n' ...
                '2. Ordinary Differential Equation (Euler):\n' ...
                '   - Example A: sin(x*y) + exp(-x)\n' ...
                '   - Example B: x^2 + y\n' ...
                '   - Example C: -2*x*y\n\n' ...
                '3. RK4 (Runge-Kutta 4th Order):\n' ...
                '   - Example A: sin(x*y) + exp(-x)\n' ...
                '   - Example B: x - y\n' ...
                '   - Example C: y*cos(x)']);
            uialert(app.UIFigure, msg, 'Help Examples', 'Icon', 'info');
        end

        % Button pushed function: btnClear
        function btnClearButtonPushed(app, ~)
            app.txtEquation.Value = 'sin(x*y) + exp(-x)';
            app.txtSolution.Value = {''};
            cla(app.UIAxes);
        end

        % Button pushed function: btnPDF
        function btnPDFButtonPushed(app, ~)
            [file, path] = uiputfile('Solution_Report.pdf', 'Save PDF Report');
            if isequal(file, 0)
                return;
            end
            f = figure('Visible', 'off', 'Position', [100 100 650 500]);
            ax = axes(f, 'Position', [0 0 1 1], 'Visible', 'off');
            
            text(0.05, 0.90, 'MultiMethod DiffSolver - Solution Report', 'FontSize', 16, 'FontWeight', 'bold');
            text(0.05, 0.82, ['Equation: ' app.txtEquation.Value], 'FontSize', 12);
            text(0.05, 0.76, ['Method Used: ' app.ddlMethod.Value], 'FontSize', 12);
            text(0.05, 0.70, 'Solution Output:', 'FontSize', 12, 'FontWeight', 'bold');
            
            solStr = strjoin(app.txtSolution.Value, '\n');
            if length(solStr) > 500
                solStr = [solStr(1:500) '... (truncated)'];
            end
            
            text(0.05, 0.45, solStr, 'FontSize', 9, 'Interpreter', 'none');
            
            exportgraphics(ax, fullfile(path, file), 'ContentType', 'vector');
            close(f);
            uialert(app.UIFigure, 'PDF Saved Successfully!', 'Success', 'Icon', 'success');
        end
    end

    % Component initialization
    methods (Access = private)
        function createComponents(app)
            % UIFigure
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 700 480];
            app.UIFigure.Name = 'MATLAB ODE Solver Suite';
            app.UIFigure.Color = [0.96 0.96 0.98];

            % Top Header Panel
            app.HeaderPanel = uipanel(app.UIFigure);
            app.HeaderPanel.Position = [0 420 700 60];
            app.HeaderPanel.BackgroundColor = [0.12 0.16 0.23];
            app.HeaderPanel.BorderType = 'none';

            % Header Label
            app.ODESolverLabel = uilabel(app.HeaderPanel);
            app.ODESolverLabel.FontSize = 20;
            app.ODESolverLabel.FontWeight = 'bold';
            app.ODESolverLabel.FontColor = [1 1 1];
            app.ODESolverLabel.Position = [20 12 300 35];
            app.ODESolverLabel.Text = 'MultiMethod DiffSolver';

            % Enter Equation Label
            app.EnterDifferentialEquationLabel = uilabel(app.UIFigure);
            app.EnterDifferentialEquationLabel.FontWeight = 'bold';
            app.EnterDifferentialEquationLabel.FontSize = 12;
            app.EnterDifferentialEquationLabel.Position = [35 365 180 22];
            app.EnterDifferentialEquationLabel.Text = 'Differential Equation:';

            % txtEquation
            app.txtEquation = uieditfield(app.UIFigure, 'text');
            app.txtEquation.Position = [210 365 210 28];
            app.txtEquation.Value = 'sin(x*y) + exp(-x)';
            app.txtEquation.FontSize = 12;

            % Select Method Label
            app.SelectMethodLabel = uilabel(app.UIFigure);
            app.SelectMethodLabel.FontWeight = 'bold';
            app.SelectMethodLabel.FontSize = 12;
            app.SelectMethodLabel.Position = [35 320 120 22];
            app.SelectMethodLabel.Text = 'Solving Method:';

            % Dropdown
            app.ddlMethod = uidropdown(app.UIFigure);
            app.ddlMethod.Items = {'Differential Equation', 'Ordinary Differential Equation', 'RK4'};
            app.ddlMethod.Position = [210 320 210 28];
            app.ddlMethod.Value = 'RK4';
            app.ddlMethod.FontSize = 12;

            % Solve Button
            app.btnSolve = uibutton(app.UIFigure, 'push');
            app.btnSolve.ButtonPushedFcn = createCallbackFcn(app, @btnSolveButtonPushed, true);
            app.btnSolve.Position = [35 265 85 34];
            app.btnSolve.Text = 'Solve';
            app.btnSolve.FontWeight = 'bold';
            app.btnSolve.FontSize = 12;
            app.btnSolve.BackgroundColor = [0.07 0.58 0.35];
            app.btnSolve.FontColor = [1 1 1];

            % Export PDF Button
            app.btnPDF = uibutton(app.UIFigure, 'push');
            app.btnPDF.ButtonPushedFcn = createCallbackFcn(app, @btnPDFButtonPushed, true);
            app.btnPDF.Position = [130 265 95 34];
            app.btnPDF.Text = 'Export PDF';
            app.btnPDF.FontWeight = 'bold';
            app.btnPDF.FontSize = 12;
            app.btnPDF.BackgroundColor = [0.85 0.35 0.15];
            app.btnPDF.FontColor = [1 1 1];

            % Help Button
            app.btnHelp = uibutton(app.UIFigure, 'push');
            app.btnHelp.ButtonPushedFcn = createCallbackFcn(app, @btnHelpButtonPushed, true);
            app.btnHelp.Position = [235 265 85 34];
            app.btnHelp.Text = 'Help';
            app.btnHelp.FontWeight = 'bold';
            app.btnHelp.FontSize = 12;
            app.btnHelp.BackgroundColor = [0.2 0.25 0.33];
            app.btnHelp.FontColor = [1 1 1];

            % Clear Button
            app.btnClear = uibutton(app.UIFigure, 'push');
            app.btnClear.ButtonPushedFcn = createCallbackFcn(app, @btnClearButtonPushed, true);
            app.btnClear.Position = [330 265 85 34];
            app.btnClear.Text = 'Clear';
            app.btnClear.FontWeight = 'bold';
            app.btnClear.FontSize = 12;

            % Solution Label
            app.SolutionLabel = uilabel(app.UIFigure);
            app.SolutionLabel.FontSize = 13;
            app.SolutionLabel.FontWeight = 'bold';
            app.SolutionLabel.Position = [35 220 100 22];
            app.SolutionLabel.Text = 'Solution:';

            % txtSolution Output Area
            app.txtSolution = uitextarea(app.UIFigure);
            app.txtSolution.Position = [35 30 380 185];
            app.txtSolution.FontSize = 11;

            % UI Axes for Graph Display
            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.Position = [435 30 245 365];
            app.UIAxes.BackgroundColor = [1 1 1];
            app.UIAxes.Box = 'on';

            % Display Window
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)
        function app = main
            createComponents(app)
            registerApp(app, app.UIFigure)
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end