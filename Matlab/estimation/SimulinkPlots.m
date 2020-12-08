set(0,'DefaultLegendAutoUpdate','off')
figure
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,1:2), 'LineWidth', 2);
hold on
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,3), 'LineWidth', 2, 'Color', 'g');
hold on
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,4), 'LineWidth', 2, 'Color', 'm');
legend({'a_4', 'a_3', 'a_2', 'a_1'}, 'Location', 'northwest');
hold on
plot(out.ScopeData1.time, a4*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'b');
hold on
plot(out.ScopeData1.time, a3*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'r');
hold on
plot(out.ScopeData1.time, a2*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'g');
hold on
plot(out.ScopeData1.time, a1*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'm');
xlabel('Time (hrs)')
ylabel('Value')
title('Plant a_n Parameter Estimations')
ylim([-10 30])

figure
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,5), 'LineWidth', 2);
hold on
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,6), 'LineWidth', 2);
hold on
legend({'b^H_1', 'b^H_0',}, 'Location', 'northwest');
plot(out.ScopeData1.time, b1_H*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'b');
hold on
plot(out.ScopeData1.time, b0_H*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'r');
xlabel('Time (hrs)')
ylabel('Value')
title('Plant b^H Parameter Estimations')
ylim([-10 90])

figure
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,7), 'LineWidth', 2);
hold on
plot(out.ScopeData1.time, b1_a*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'b');
xlabel('Time (hrs)')
ylabel('Value')
title('Plant b^{T_a}_1 Parameter Estimation')

figure
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,8), 'LineWidth', 2);
hold on
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,9), 'LineWidth', 2, 'Color', 'r');
hold on
plot(out.ScopeData1.time, out.ScopeData1.signals.values(:,10), 'LineWidth', 2, 'Color', 'g');
legend({'b^\phi_2', 'b^\phi_1', 'b^\phi_0'}, 'Location', 'northwest');
hold on
plot(out.ScopeData1.time, 9.7415*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'b');
hold on
plot(out.ScopeData1.time, 81.1961*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'r');
hold on
plot(out.ScopeData1.time, 47.3258*ones(length(out.ScopeData1.signals.values(:,1)),1),'--', 'Color', 'g');
xlabel('Time (hrs)')
ylabel('Value')
title('Plant \phi_s Parameter Estimations')
ylim([-10 90])

figure
plot(out.ScopeData2.time, out.ScopeData2.signals(1).values(:,1));
hold on
plot(out.ScopeData2.time, out.ScopeData2.signals(2).values(:,1), 'Color', 'r');
xlabel('Time (hrs)')
ylabel('Value')
title('Estimated Ts From Observer vs Actual')
legend('Estimated Ts', 'Ts');
ylim([0, 30])
