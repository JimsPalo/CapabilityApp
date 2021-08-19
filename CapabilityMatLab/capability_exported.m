classdef capability_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        DiagramdecapabilidadTab         matlab.ui.container.Tab
        CapabilitydiagramPanel          matlab.ui.container.Panel
        FemMaxSlider                    matlab.ui.control.Slider
        FemintenamximapuSliderLabel     matlab.ui.control.Label
        FemSpinner                      matlab.ui.control.Spinner
        LimSupSpinner                   matlab.ui.control.Spinner
        limSupSlider                    matlab.ui.control.Slider
        LimSupSliderLabel               matlab.ui.control.Label
        LimInfSlider                    matlab.ui.control.Slider
        LmiteinferiordeoperacinSliderLabel  matlab.ui.control.Label
        LimInfSpinner                   matlab.ui.control.Spinner
        LimtherSlider                   matlab.ui.control.Slider
        LmitetermicoestatorSliderLabel  matlab.ui.control.Label
        LimtherSpinner                  matlab.ui.control.Spinner
        EstabMargeSlider                matlab.ui.control.Slider
        MargendeseguridaddeestabilidadSliderLabel  matlab.ui.control.Label
        EstabMargeSpinner               matlab.ui.control.Spinner
        ResiMargSlider                  matlab.ui.control.Slider
        MargendeseguridadmagnetismoresidualLabel  matlab.ui.control.Label
        ResisuMargSpinner               matlab.ui.control.Spinner
        UIAxes                          matlab.ui.control.UIAxes
        DiagramafasorialTab             matlab.ui.container.Tab
        UIAxes2                         matlab.ui.control.UIAxes
        InfromacindeentradaPanel        matlab.ui.container.Panel
        ByJimmyPalominoLabel            matlab.ui.control.Label
        Hyperlink                       matlab.ui.control.Hyperlink
        AplicarButton                   matlab.ui.control.Button
        XdSpinner                       matlab.ui.control.Spinner
        XdpuSlider                      matlab.ui.control.Slider
        XdpuSliderLabel                 matlab.ui.control.Label
        XqpuSlider                      matlab.ui.control.Slider
        XqpuSliderLabel                 matlab.ui.control.Label
        XqSpinner                       matlab.ui.control.Spinner
        VoltajeSlider                   matlab.ui.control.Slider
        VoltajeSliderLabel              matlab.ui.control.Label
        VoltajeSpinner                  matlab.ui.control.Spinner
        PotenciaAparentepuSlider        matlab.ui.control.Slider
        PotenciaAparentepuSliderLabel   matlab.ui.control.Label
        Spinner                         matlab.ui.control.Spinner
        PFSlider                        matlab.ui.control.Slider
        PFSliderLabel                   matlab.ui.control.Label
        PFSpinner                       matlab.ui.control.Spinner
        InductivoCheckBox               matlab.ui.control.CheckBox
        CapacitivoCheckBox              matlab.ui.control.CheckBox
    end

    
    methods (Access = private)
        
        function Capability_diagram(app)
            % Load Data
            Xd=app.XdpuSlider.Value;
            Xq=app.XqpuSlider.Value;
            V=app.VoltajeSlider.Value;
%             S=app.PotenciaAparentepuSlider.Value;
%             pf=app.PFSlider.Value;
            
            % Create the plot
            axis(app.UIAxes, 'equal')
            % Maximum output power in the machine
            x=-1.5:0.01:1.5;
            % ones arrange
            ones1=ones(size(x));
            plot(app.UIAxes, x,ones1.*app.limSupSlider.Value)
            % hold on Axis
            hold(app.UIAxes, 'on')
            % Minimum output powere in the machine
            plot(app.UIAxes, x, ones1.*app.LimInfSlider.Value)
            % thermical limitation stator
            radious_st=app.LimtherSlider.Value;
            Stator_thermical=@(x) sqrt(radious_st^2-x^2);
            fplot(app.UIAxes, Stator_thermical, [radious_st*-1, radious_st])
            % Magnetization limit
            radious_mg=V*(Xd/Xq-1)*V/Xd/2;
            Vp=V*V/Xd;
            xdelay=Vp+radious_mg;
            dr=app.ResiMargSlider.Value; % delta radious
            Magnetization_circle=@(x) sqrt((radious_mg.*(dr+1))^2-(x+xdelay).^2);
            fplot(app.UIAxes, Magnetization_circle, [(Vp*-1+radious_mg*-2)*(0.999+dr), -Vp*(0.999-dr)])
            % thermal rotor limit
            Magnetization_circle=@(x) sqrt((radious_mg)^2-(x+xdelay).^2);
            fem=app.FemMaxSlider.Value*V/Xd;
            X3=zeros(size((Vp*-1+radious_mg*-2)*1.02:0.01:-Vp*0.98));
            Y3=zeros(size((Vp*-1+radious_mg*-2)*1.02:0.01:-Vp*0.98));
            c=0;
            for k=(Vp*-1+radious_mg*-2)*1.02:0.01:-Vp*0.98
                 c=c+1;
                 Y0=Magnetization_circle(k);
                 % X1=V+D-x
                 X1=Vp+radious_mg*2+k;
                 thetha0=atan(Y0/X1);
                 Hip=sqrt(X1^2+Y0^2);
                 Radi=Hip+fem;
                 X3(c)=Radi*cos(thetha0)-Vp-radious_mg*2;
                 Y3(c)=Radi*sin(thetha0);
            end
            plot(app.UIAxes, X3, Y3)
            
            % Stability limit
            P1=0.1:0.01:1.7;
            Pmax=app.limSupSlider.Value;
            P0=P1-Pmax*app.EstabMargeSlider.Value/100;
            Q0=zeros(1,length(P0));
            for k=1:length(P0)
                d1=fzero(@(x) (-V^2*cos(2*x)*tan(x)+V^2/2*sin(2*x))*(1/Xq-1/Xd)-P1(k),[0, pi/2]);
                E1=-V*cos(2*d1)*Xd*(1/Xq-1/Xd)/cos(d1);
                delta0=fzero(@(x) E1*V/Xd*sin(x)+V^2/2*(1/Xq-1/Xd)*sin(2*x)-P0(k),pi/4);
                Q0(k)=(E1*V*Xd*cos(delta0))+((V^2/2*(1/Xq-1/Xd))*cos(2*delta0))-(((V^2)/2*(1/Xq+1/Xd)));
            end
            plot(app.UIAxes, Q0, P0);
            
            
            
            
            
%             c=1;
%             x4=[-Vp-radious_mg*2, 0];
%             y4=[0 0];
%             for k=0:0.1:1.5
%                 c=c+1;
%                 crl=@(x) -1*sqrt(radious_mg^2-(x+xdelay).^2)+k;
%                 
%                 x1=-xdelay+radious_mg;
%                 y1=crl(x1);
% %                 x0=-Vp-radious_mg*2;
% %                 y0=0;
%                 m=(y1-y4(1))/(x1-x4(1));
%                 b=y1-m*x1;
%                 
%                 fzv=@(x) -1*sqrt(radious_mg^2-(x+xdelay).^2)+k-(m*x+b);
%                 crl(-xdelay)
%                 x4(c)=fzero(fzv, -xdelay);
%                 y4(c)=crl(x4(c));
%             end
%             
%             
%             
%             plot(app.UIAxes, x4, y4)
            
            
            
            hold(app.UIAxes, 'off')
        end
        
        % Grafico de fasores
        function diagram_phasor(app)
            Xd=app.XdpuSlider.Value;
            Xq=app.XqpuSlider.Value;
            V=app.VoltajeSlider.Value;
            S=app.PotenciaAparentepuSlider.Value;
            pf=app.PFSlider.Value;
            
            axis(app.UIAxes2, 'equal');
            plot(app.UIAxes2,[0,1],[0,0])
            text(app.UIAxes2,1,0,texlabel('V'))
            hold(app.UIAxes2,'on')
            % corriente
            if app.CapacitivoCheckBox.Value==true
                a=1;
            else
                a=-1;
            end
            current = S/V*exp(1i*a*acos(pf));
            plot(app.UIAxes2,[0,real(current)],[0,imag(current)])
            text(app.UIAxes2,real(current),imag(current),texlabel('I_load'))
            
            % I*Xq
            IXq=current*(1j*Xq);
            plot(app.UIAxes2,[1,real(IXq)+1],[0,imag(IXq)])
            text(app.UIAxes2,real(IXq)+1,imag(IXq),texlabel('I*(X_q)'))

            
            % I*Xq+V
            Ep=IXq+1;
            
            % I*(Xd-Xq)
            IXdq=current*(1j*(Xd-Xq));
            plot(app.UIAxes2,[real(Ep),real(IXdq)+real(Ep)],[imag(Ep),imag(IXdq)+imag(Ep)],"LineStyle",'--' )
            text(app.UIAxes2,real(IXdq)+real(Ep),imag(IXdq)+imag(Ep),texlabel('I*(X_d-X_q)'))
            
            E0m=abs(Ep)+abs(current*(1j*(Xd-Xq)))*sin(angle(Ep)-angle(current));
            E0=E0m*exp(1j*angle(Ep));
            plot(app.UIAxes2,[0,real(E0)],[0,imag(E0)])
            
            text(app.UIAxes2,real(E0),imag(E0),texlabel('E_0'))
%             hold(app.UIAxes,'on')
%             plot(app.UIAxes, real(E0)*V/Xd,imag(E0)*V/Xd, 'Marker',"x")
%             hold(app.UIAxes,'off')
            
            hold(app.UIAxes2,'off')
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: AplicarButton
        function AplicarButtonPushed(app, event)
            Capability_diagram(app)
            diagram_phasor(app)
        end

        % Value changing function: XdpuSlider
        function XdpuSliderValueChanging(app, event)
            changingValue = event.Value;
            app.XdSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: XdSpinner
        function XdSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.XdpuSlider.Value=str2double(changingValue);
            else
                app.XdpuSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changing function: XqpuSlider
        function XqpuSliderValueChanging(app, event)
            changingValue = event.Value;
            app.XqSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: XqSpinner
        function XqSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.XqpuSlider.Value=str2double(changingValue);
            else
                app.XqpuSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changing function: VoltajeSlider
        function VoltajeSliderValueChanging(app, event)
            changingValue = event.Value;
            app.VoltajeSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: VoltajeSpinner
        function VoltajeSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.VoltajeSlider.Value=str2double(changingValue);
            else
                app.VoltajeSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changing function: PotenciaAparentepuSlider
        function PotenciaAparentepuSliderValueChanging(app, event)
            changingValue = event.Value;
            app.Spinner.Value=changingValue;
            diagram_phasor(app)
        end

        % Value changing function: Spinner
        function SpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.PotenciaAparentepuSlider.Value=str2double(changingValue);
            else
                app.PotenciaAparentepuSlider.Value=changingValue;
            end
            diagram_phasor(app)
        end

        % Value changing function: PFSlider
        function PFSliderValueChanging(app, event)
            changingValue = event.Value;
            app.PFSpinner.Value=changingValue;
            diagram_phasor(app)
        end

        % Value changing function: PFSpinner
        function PFSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.PFSlider.Value=str2double(changingValue);
            else
                app.PFSlider.Value=changingValue;
            end
            diagram_phasor(app)
        end

        % Value changing function: limSupSlider
        function limSupSliderValueChanging(app, event)
            changingValue = event.Value;
            app.LimSupSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: LimSupSpinner
        function LimSupSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.limSupSlider.Value=str2double(changingValue);
            else
                app.limSupSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changing function: LimInfSlider
        function LimInfSliderValueChanging(app, event)
            changingValue = event.Value;
            app.LimInfSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: LimInfSpinner
        function LimInfSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.LimInfSlider.Value=str2double(changingValue);
            else
                app.LimInfSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changing function: LimtherSlider
        function LimtherSliderValueChanging(app, event)
            changingValue = event.Value;
            app.LimtherSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: LimtherSpinner
        function LimtherSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.LimtherSlider.Value=str2double(changingValue);
            else
                app.LimtherSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changing function: EstabMargeSlider
        function EstabMargeSliderValueChanging(app, event)
            changingValue = event.Value;
            app.EstabMargeSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: EstabMargeSpinner
        function EstabMargeSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.EstabMargeSlider.Value=str2double(changingValue);
            else
                app.EstabMargeSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changing function: ResiMargSlider
        function ResiMargSliderValueChanging(app, event)
            changingValue = event.Value;
            app.ResisuMargSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: ResisuMargSpinner
        function ResisuMargSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.ResiMargSlider.Value=str2double(changingValue);
            else
                app.ResiMargSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changing function: FemMaxSlider
        function FemMaxSliderValueChanging(app, event)
            changingValue = event.Value;
            app.FemSpinner.Value=changingValue;
            Capability_diagram(app)
        end

        % Value changing function: FemSpinner
        function FemSpinnerValueChanging(app, event)
            changingValue = event.Value;
            if ischar(changingValue)
                app.FemMaxSlider.Value=str2double(changingValue);
            else
                app.FemMaxSlider.Value=changingValue;
            end
            Capability_diagram(app)
        end

        % Value changed function: InductivoCheckBox
        function InductivoCheckBoxValueChanged(app, event)
            value = app.InductivoCheckBox.Value;
            if value==true
                app.CapacitivoCheckBox.Value=false;
            else
                app.InductivoCheckBox.Value=true;
            end
            diagram_phasor(app)
        end

        % Value changed function: CapacitivoCheckBox
        function CapacitivoCheckBoxValueChanged(app, event)
            value = app.CapacitivoCheckBox.Value;
            if value==true
                app.InductivoCheckBox.Value=false;
            else
                app.CapacitivoCheckBox.Value=true;
            end
            diagram_phasor(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1418 686];
            app.UIFigure.Name = 'UI Figure';

            % Create InfromacindeentradaPanel
            app.InfromacindeentradaPanel = uipanel(app.UIFigure);
            app.InfromacindeentradaPanel.Title = 'Infromación de entrada';
            app.InfromacindeentradaPanel.Position = [1 -3 320 690];

            % Create CapacitivoCheckBox
            app.CapacitivoCheckBox = uicheckbox(app.InfromacindeentradaPanel);
            app.CapacitivoCheckBox.ValueChangedFcn = createCallbackFcn(app, @CapacitivoCheckBoxValueChanged, true);
            app.CapacitivoCheckBox.Text = 'Capacitivo ';
            app.CapacitivoCheckBox.Position = [193 209 81 22];

            % Create InductivoCheckBox
            app.InductivoCheckBox = uicheckbox(app.InfromacindeentradaPanel);
            app.InductivoCheckBox.ValueChangedFcn = createCallbackFcn(app, @InductivoCheckBoxValueChanged, true);
            app.InductivoCheckBox.Text = 'Inductivo';
            app.InductivoCheckBox.Position = [43 209 70 22];
            app.InductivoCheckBox.Value = true;

            % Create PFSpinner
            app.PFSpinner = uispinner(app.InfromacindeentradaPanel);
            app.PFSpinner.Step = 0.05;
            app.PFSpinner.ValueChangingFcn = createCallbackFcn(app, @PFSpinnerValueChanging, true);
            app.PFSpinner.Limits = [0 1];
            app.PFSpinner.Position = [201 269 100 22];
            app.PFSpinner.Value = 0.8;

            % Create PFSliderLabel
            app.PFSliderLabel = uilabel(app.InfromacindeentradaPanel);
            app.PFSliderLabel.HorizontalAlignment = 'right';
            app.PFSliderLabel.Position = [180 299 25 22];
            app.PFSliderLabel.Text = 'PF';

            % Create PFSlider
            app.PFSlider = uislider(app.InfromacindeentradaPanel);
            app.PFSlider.Limits = [0 1];
            app.PFSlider.ValueChangingFcn = createCallbackFcn(app, @PFSliderValueChanging, true);
            app.PFSlider.Position = [35 281 150 3];
            app.PFSlider.Value = 0.8;

            % Create Spinner
            app.Spinner = uispinner(app.InfromacindeentradaPanel);
            app.Spinner.Step = 0.05;
            app.Spinner.ValueChangingFcn = createCallbackFcn(app, @SpinnerValueChanging, true);
            app.Spinner.Limits = [0 2];
            app.Spinner.Position = [203 350 100 22];
            app.Spinner.Value = 1;

            % Create PotenciaAparentepuSliderLabel
            app.PotenciaAparentepuSliderLabel = uilabel(app.InfromacindeentradaPanel);
            app.PotenciaAparentepuSliderLabel.HorizontalAlignment = 'right';
            app.PotenciaAparentepuSliderLabel.Position = [120 379 127 22];
            app.PotenciaAparentepuSliderLabel.Text = 'Potencia Aparente [pu]';

            % Create PotenciaAparentepuSlider
            app.PotenciaAparentepuSlider = uislider(app.InfromacindeentradaPanel);
            app.PotenciaAparentepuSlider.Limits = [0 2];
            app.PotenciaAparentepuSlider.ValueChangingFcn = createCallbackFcn(app, @PotenciaAparentepuSliderValueChanging, true);
            app.PotenciaAparentepuSlider.Position = [35 363 150 3];
            app.PotenciaAparentepuSlider.Value = 1;

            % Create VoltajeSpinner
            app.VoltajeSpinner = uispinner(app.InfromacindeentradaPanel);
            app.VoltajeSpinner.Step = 0.05;
            app.VoltajeSpinner.ValueChangingFcn = createCallbackFcn(app, @VoltajeSpinnerValueChanging, true);
            app.VoltajeSpinner.Limits = [0.25 2];
            app.VoltajeSpinner.Position = [208 431 100 22];
            app.VoltajeSpinner.Value = 1;

            % Create VoltajeSliderLabel
            app.VoltajeSliderLabel = uilabel(app.InfromacindeentradaPanel);
            app.VoltajeSliderLabel.HorizontalAlignment = 'right';
            app.VoltajeSliderLabel.Position = [170 461 41 22];
            app.VoltajeSliderLabel.Text = 'Voltaje';

            % Create VoltajeSlider
            app.VoltajeSlider = uislider(app.InfromacindeentradaPanel);
            app.VoltajeSlider.Limits = [0.25 2];
            app.VoltajeSlider.ValueChangingFcn = createCallbackFcn(app, @VoltajeSliderValueChanging, true);
            app.VoltajeSlider.Position = [42 443 150 3];
            app.VoltajeSlider.Value = 1;

            % Create XqSpinner
            app.XqSpinner = uispinner(app.InfromacindeentradaPanel);
            app.XqSpinner.Step = 0.05;
            app.XqSpinner.ValueChangingFcn = createCallbackFcn(app, @XqSpinnerValueChanging, true);
            app.XqSpinner.Limits = [0.4 1];
            app.XqSpinner.Position = [203 513 100 22];
            app.XqSpinner.Value = 0.7;

            % Create XqpuSliderLabel
            app.XqpuSliderLabel = uilabel(app.InfromacindeentradaPanel);
            app.XqpuSliderLabel.HorizontalAlignment = 'right';
            app.XqpuSliderLabel.Position = [166 543 43 22];
            app.XqpuSliderLabel.Text = 'Xq [pu]';

            % Create XqpuSlider
            app.XqpuSlider = uislider(app.InfromacindeentradaPanel);
            app.XqpuSlider.Limits = [0.4 1];
            app.XqpuSlider.ValueChangingFcn = createCallbackFcn(app, @XqpuSliderValueChanging, true);
            app.XqpuSlider.Position = [38 525 150 3];
            app.XqpuSlider.Value = 0.7;

            % Create XdpuSliderLabel
            app.XdpuSliderLabel = uilabel(app.InfromacindeentradaPanel);
            app.XdpuSliderLabel.HorizontalAlignment = 'right';
            app.XdpuSliderLabel.Position = [175 629 43 22];
            app.XdpuSliderLabel.Text = 'Xd [pu]';

            % Create XdpuSlider
            app.XdpuSlider = uislider(app.InfromacindeentradaPanel);
            app.XdpuSlider.Limits = [0.6 1.5];
            app.XdpuSlider.ValueChangingFcn = createCallbackFcn(app, @XdpuSliderValueChanging, true);
            app.XdpuSlider.Position = [38 608 150 3];
            app.XdpuSlider.Value = 1.1;

            % Create XdSpinner
            app.XdSpinner = uispinner(app.InfromacindeentradaPanel);
            app.XdSpinner.Step = 0.05;
            app.XdSpinner.ValueChangingFcn = createCallbackFcn(app, @XdSpinnerValueChanging, true);
            app.XdSpinner.Limits = [0.6 1.5];
            app.XdSpinner.Position = [203 598 100 22];
            app.XdSpinner.Value = 1.1;

            % Create AplicarButton
            app.AplicarButton = uibutton(app.InfromacindeentradaPanel, 'push');
            app.AplicarButton.ButtonPushedFcn = createCallbackFcn(app, @AplicarButtonPushed, true);
            app.AplicarButton.Position = [80 148 100 22];
            app.AplicarButton.Text = 'Aplicar';

            % Create Hyperlink
            app.Hyperlink = uihyperlink(app.InfromacindeentradaPanel);
            app.Hyperlink.URL = 'https://www.linkedin.com/in/jimmypalomino/';
            app.Hyperlink.Position = [21 11 117 22];
            app.Hyperlink.Text = 'LinkedIn Developer';

            % Create ByJimmyPalominoLabel
            app.ByJimmyPalominoLabel = uilabel(app.InfromacindeentradaPanel);
            app.ByJimmyPalominoLabel.Position = [21 32 108 22];
            app.ByJimmyPalominoLabel.Text = 'By Jimmy Palomino';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [331 7 1080 680];

            % Create DiagramdecapabilidadTab
            app.DiagramdecapabilidadTab = uitab(app.TabGroup);
            app.DiagramdecapabilidadTab.Title = 'Diagram de capabilidad';

            % Create UIAxes
            app.UIAxes = uiaxes(app.DiagramdecapabilidadTab);
            title(app.UIAxes, 'Capability diagram')
            xlabel(app.UIAxes, 'MVAR [pu]')
            ylabel(app.UIAxes, 'MW [pu]')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.XMinorGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.YMinorGrid = 'on';
            app.UIAxes.Position = [20 21 690 560];

            % Create CapabilitydiagramPanel
            app.CapabilitydiagramPanel = uipanel(app.DiagramdecapabilidadTab);
            app.CapabilitydiagramPanel.Title = 'Capability diagram';
            app.CapabilitydiagramPanel.Position = [735 70 320 570];

            % Create ResisuMargSpinner
            app.ResisuMargSpinner = uispinner(app.CapabilitydiagramPanel);
            app.ResisuMargSpinner.Step = 0.05;
            app.ResisuMargSpinner.ValueChangingFcn = createCallbackFcn(app, @ResisuMargSpinnerValueChanging, true);
            app.ResisuMargSpinner.Limits = [0 0.7];
            app.ResisuMargSpinner.Position = [201 149 100 22];
            app.ResisuMargSpinner.Value = 0.1;

            % Create MargendeseguridadmagnetismoresidualLabel
            app.MargendeseguridadmagnetismoresidualLabel = uilabel(app.CapabilitydiagramPanel);
            app.MargendeseguridadmagnetismoresidualLabel.HorizontalAlignment = 'right';
            app.MargendeseguridadmagnetismoresidualLabel.Position = [47 179 238 22];
            app.MargendeseguridadmagnetismoresidualLabel.Text = 'Margen de seguridad magnetismo residual ';

            % Create ResiMargSlider
            app.ResiMargSlider = uislider(app.CapabilitydiagramPanel);
            app.ResiMargSlider.Limits = [0 0.7];
            app.ResiMargSlider.ValueChangingFcn = createCallbackFcn(app, @ResiMargSliderValueChanging, true);
            app.ResiMargSlider.Position = [35 161 150 3];
            app.ResiMargSlider.Value = 0.1;

            % Create EstabMargeSpinner
            app.EstabMargeSpinner = uispinner(app.CapabilitydiagramPanel);
            app.EstabMargeSpinner.Step = 0.05;
            app.EstabMargeSpinner.ValueChangingFcn = createCallbackFcn(app, @EstabMargeSpinnerValueChanging, true);
            app.EstabMargeSpinner.Limits = [0 70];
            app.EstabMargeSpinner.Position = [203 230 100 22];
            app.EstabMargeSpinner.Value = 10;

            % Create MargendeseguridaddeestabilidadSliderLabel
            app.MargendeseguridaddeestabilidadSliderLabel = uilabel(app.CapabilitydiagramPanel);
            app.MargendeseguridaddeestabilidadSliderLabel.HorizontalAlignment = 'right';
            app.MargendeseguridaddeestabilidadSliderLabel.Position = [60 259 212 22];
            app.MargendeseguridaddeestabilidadSliderLabel.Text = 'Margen de seguridad de estabilidad %';

            % Create EstabMargeSlider
            app.EstabMargeSlider = uislider(app.CapabilitydiagramPanel);
            app.EstabMargeSlider.Limits = [0 70];
            app.EstabMargeSlider.ValueChangingFcn = createCallbackFcn(app, @EstabMargeSliderValueChanging, true);
            app.EstabMargeSlider.Position = [35 243 150 3];
            app.EstabMargeSlider.Value = 10;

            % Create LimtherSpinner
            app.LimtherSpinner = uispinner(app.CapabilitydiagramPanel);
            app.LimtherSpinner.Step = 0.05;
            app.LimtherSpinner.ValueChangingFcn = createCallbackFcn(app, @LimtherSpinnerValueChanging, true);
            app.LimtherSpinner.Limits = [0.25 2];
            app.LimtherSpinner.Position = [208 311 100 22];
            app.LimtherSpinner.Value = 1;

            % Create LmitetermicoestatorSliderLabel
            app.LmitetermicoestatorSliderLabel = uilabel(app.CapabilitydiagramPanel);
            app.LmitetermicoestatorSliderLabel.HorizontalAlignment = 'right';
            app.LmitetermicoestatorSliderLabel.Position = [130 341 121 22];
            app.LmitetermicoestatorSliderLabel.Text = 'Límite termico estator';

            % Create LimtherSlider
            app.LimtherSlider = uislider(app.CapabilitydiagramPanel);
            app.LimtherSlider.Limits = [0.5 1.5];
            app.LimtherSlider.ValueChangingFcn = createCallbackFcn(app, @LimtherSliderValueChanging, true);
            app.LimtherSlider.Position = [42 323 150 3];
            app.LimtherSlider.Value = 1;

            % Create LimInfSpinner
            app.LimInfSpinner = uispinner(app.CapabilitydiagramPanel);
            app.LimInfSpinner.Step = 0.05;
            app.LimInfSpinner.ValueChangingFcn = createCallbackFcn(app, @LimInfSpinnerValueChanging, true);
            app.LimInfSpinner.Limits = [0 1];
            app.LimInfSpinner.Position = [203 393 100 22];
            app.LimInfSpinner.Value = 0.1;

            % Create LmiteinferiordeoperacinSliderLabel
            app.LmiteinferiordeoperacinSliderLabel = uilabel(app.CapabilitydiagramPanel);
            app.LmiteinferiordeoperacinSliderLabel.HorizontalAlignment = 'right';
            app.LmiteinferiordeoperacinSliderLabel.Position = [100 423 151 22];
            app.LmiteinferiordeoperacinSliderLabel.Text = 'Límite inferior de operación';

            % Create LimInfSlider
            app.LimInfSlider = uislider(app.CapabilitydiagramPanel);
            app.LimInfSlider.Limits = [0 1];
            app.LimInfSlider.ValueChangingFcn = createCallbackFcn(app, @LimInfSliderValueChanging, true);
            app.LimInfSlider.Position = [38 405 150 3];
            app.LimInfSlider.Value = 0.1;

            % Create LimSupSliderLabel
            app.LimSupSliderLabel = uilabel(app.CapabilitydiagramPanel);
            app.LimSupSliderLabel.HorizontalAlignment = 'right';
            app.LimSupSliderLabel.Position = [71 509 191 22];
            app.LimSupSliderLabel.Text = 'Límites superior de operación [pu] ';

            % Create limSupSlider
            app.limSupSlider = uislider(app.CapabilitydiagramPanel);
            app.limSupSlider.Limits = [0 1];
            app.limSupSlider.ValueChangingFcn = createCallbackFcn(app, @limSupSliderValueChanging, true);
            app.limSupSlider.Position = [38 488 150 3];
            app.limSupSlider.Value = 0.9;

            % Create LimSupSpinner
            app.LimSupSpinner = uispinner(app.CapabilitydiagramPanel);
            app.LimSupSpinner.Step = 0.05;
            app.LimSupSpinner.ValueChangingFcn = createCallbackFcn(app, @LimSupSpinnerValueChanging, true);
            app.LimSupSpinner.Limits = [0 1];
            app.LimSupSpinner.Position = [203 478 100 22];
            app.LimSupSpinner.Value = 0.9;

            % Create FemSpinner
            app.FemSpinner = uispinner(app.CapabilitydiagramPanel);
            app.FemSpinner.Step = 0.05;
            app.FemSpinner.ValueChangingFcn = createCallbackFcn(app, @FemSpinnerValueChanging, true);
            app.FemSpinner.Limits = [1.5 2];
            app.FemSpinner.Position = [202 62 100 22];
            app.FemSpinner.Value = 2;

            % Create FemintenamximapuSliderLabel
            app.FemintenamximapuSliderLabel = uilabel(app.CapabilitydiagramPanel);
            app.FemintenamximapuSliderLabel.HorizontalAlignment = 'right';
            app.FemintenamximapuSliderLabel.Position = [118 92 134 22];
            app.FemintenamximapuSliderLabel.Text = 'Fem intena máxima [pu]';

            % Create FemMaxSlider
            app.FemMaxSlider = uislider(app.CapabilitydiagramPanel);
            app.FemMaxSlider.Limits = [1.5 2];
            app.FemMaxSlider.ValueChangingFcn = createCallbackFcn(app, @FemMaxSliderValueChanging, true);
            app.FemMaxSlider.Position = [36 74 150 3];
            app.FemMaxSlider.Value = 2;

            % Create DiagramafasorialTab
            app.DiagramafasorialTab = uitab(app.TabGroup);
            app.DiagramafasorialTab.Title = 'Diagrama fasorial';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.DiagramafasorialTab);
            title(app.UIAxes2, 'Diagrama fasorial')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.Position = [121 85 730 500];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = capability_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end