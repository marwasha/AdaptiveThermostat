%% Plot all data
set(0,'DefaultLegendAutoUpdate','off')
plantTfCoef;
figure
plot(tS, thetaS(:,1:2), 'LineWidth', 2);
hold on
plot(tS, thetaS(:,3), 'LineWidth', 2, 'Color', 'g');
hold on
plot(tS, thetaS(:,4), 'LineWidth', 2, 'Color', 'm');
legend({'a_4', 'a_3', 'a_2', 'a_1'}, 'Location', 'northwest');
hold on
plot(tS, a4*ones(length(thetaS(:,1)),1),'--', 'Color', 'b');
hold on
plot(tS, a3*ones(length(thetaS(:,1)),1),'--', 'Color', 'r');
hold on
plot(tS, a2*ones(length(thetaS(:,1)),1),'--', 'Color', 'g');
hold on
plot(tS, a1*ones(length(thetaS(:,1)),1),'--', 'Color', 'm');
xlabel('Time (hrs)')
ylabel('Value')
title('Plant a_n Parameter Estimations')
ylim([-10 30])

figure
plot(tS, thetaS(:,5), 'LineWidth', 2);
hold on
plot(tS, thetaS(:,6), 'LineWidth', 2);
hold on
legend({'b^H_1', 'b^H_0',}, 'Location', 'northwest');
plot(tS, b1_H*ones(length(thetaS(:,1)),1),'--', 'Color', 'b');
hold on
plot(tS, b0_H*ones(length(thetaS(:,1)),1),'--', 'Color', 'r');
xlabel('Time (hrs)')
ylabel('Value')
title('Plant b^H Parameter Estimations')
ylim([-10 90])

figure
plot(tS, thetaS(:,7), 'LineWidth', 2);
hold on
plot(tS, b1_a*ones(length(thetaS(:,1)),1),'--', 'Color', 'b');
xlabel('Time (hrs)')
ylabel('Value')
title('Plant b^{T_a}_1 Parameter Estimation')

figure
plot(tS, thetaS(:,8), 'LineWidth', 2);
hold on
plot(tS, thetaS(:,9), 'LineWidth', 2, 'Color', 'r');
hold on
plot(tS, thetaS(:,10), 'LineWidth', 2, 'Color', 'g');
legend({'b^\phi_2', 'b^\phi_1', 'b^\phi_0'}, 'Location', 'northwest');
hold on
plot(tS, b2_s*ones(length(thetaS(:,1)),1),'--', 'Color', 'b');
hold on
plot(tS, b1_s*ones(length(thetaS(:,1)),1),'--', 'Color', 'r');
hold on
plot(tS, b0_s*ones(length(thetaS(:,1)),1),'--', 'Color', 'g');
xlabel('Time (hrs)')
ylabel('Value')
title('Plant \phi_s Parameter Estimations')
ylim([-10 90])

figure
plot(tS, xhatS(:,1), 'LineWidth', 2);
hold on
plot(tS, xactS(:,1), 'Color', 'g', 'LineWidth', 2);
hold on
plot(tS, TSPrev(1:length(tS))+1,'--', 'Color', 'r');
hold on
plot(tS, TSPrev(1:length(tS))-1,'--', 'Color', 'm');
xlabel('Time (hrs)')
ylabel('Value')
title('Estimated Ts From Observer vs Actual')
legend('Estimated Ts', 'Ts');
ylim([0, 30])

