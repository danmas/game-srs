import Phaser from 'phaser';
import { Ship } from '../objects/Ship';
import { MainScene } from '../scenes/MainScene';
import { Constants } from '../utils/Constants';
import { Settings } from '../utils/Settings';

export class AIWeaponControl {
    private owner: Ship;
    private mainScene: MainScene;

    constructor(owner: Ship, scene: MainScene) {
        this.owner = owner;
        this.mainScene = scene;
    }

    public evaluateAndFire(allShips: Ship[]): void {
        if (!this.owner || !this.mainScene) {
            console.error("AIWeaponControl: Owner or MainScene is not set!");
            return;
        }

        let enemyShips: Ship[] = [];
        if (this.owner.getForces() === Constants.FORCES_RED) {
            enemyShips = allShips.filter((s) => s.active && s.getForces() === Constants.FORCES_WHITE);
        } else {
            enemyShips = allShips.filter((s) => s.active && s.getForces() === Constants.FORCES_RED);
        }

        const activeEnemies = enemyShips;

        if (activeEnemies.length > 0) {
            const targetCandidate = activeEnemies[0]; 

            if (!targetCandidate) {
                 console.log(`   AI Ship ${this.owner.id}: Нет активных врагов для выбора в качестве цели (targetCandidate is null/undefined).`);
                 return; 
            }

            if (!(targetCandidate instanceof Ship)) {
                 console.log(`   AI Ship ${this.owner.id}: Кандидат в цели (ID: ${ (targetCandidate as any)?.id || 'N/A' }) не является экземпляром Ship.`);
                 return; 
            }
            
            const target: Ship = targetCandidate;

            const weaponReady = this.owner.isWeaponReady(Constants.WEAPON_SELECT_TORP_I);
            const distanceToTarget = Phaser.Math.Distance.Between(this.owner.x, this.owner.y, target.x, target.y);
            const angleToTargetRad = Phaser.Math.Angle.Between(this.owner.x, this.owner.y, target.x, target.y);
            let angleToTargetDeg = (Phaser.Math.RadToDeg(angleToTargetRad) + 90 + 360) % 360;
            const diffAngle = Phaser.Math.Angle.ShortestBetween(this.owner.getDirection(), angleToTargetDeg);

            console.log(`--- AI Ship ${this.owner.id} (контроллер оружия хочет атаковать Цель ID ${target.id}) ---`);
            console.log(`   Количество врагов: ${activeEnemies.length}`);
            console.log(`   Оружие (Торп.I) готово: ${weaponReady} (На борту: ${this.owner.getTorpOnBoard(Constants.WEAPON_SELECT_TORP_I)}, Время перезарядки: ${(this.owner as any).reloadTimeTorp1} мс)`);
            
            const distanceOk = distanceToTarget < Settings.TRP_I_DIST_EXECUTION;
            console.log(`   Дистанция до цели: ${distanceToTarget.toFixed(1)} (Макс. для атаки: ${Settings.TRP_I_DIST_EXECUTION}) -> ${distanceOk ? 'OK' : 'ДАЛЕКО'}`);
            
            const angleOk = Math.abs(diffAngle) < Settings.TRP_ATACK__ANGLE_WARNING;
            console.log(`   Угол на цель (отклонение от курса): ${diffAngle.toFixed(1)}° (Макс. допуск: ${Settings.TRP_ATACK__ANGLE_WARNING}°) -> ${angleOk ? 'OK' : 'НЕ ПО КУРСУ'}`);

            if (target && weaponReady && distanceOk && angleOk) {
                console.log(`   >>> AI Ship ${this.owner.id}: УСЛОВИЯ ВЫПОЛНЕНЫ! СТРЕЛЯЮ Торпедой I по Цели ${target.id} (Координаты: X:${target.x.toFixed(0)}, Y:${target.y.toFixed(0)})`);
                this.mainScene.fireTorpedo(this.owner, Constants.WEAPON_SELECT_TORP_I, target.x, target.y);
            } else {
                console.log(`   --- AI Ship ${this.owner.id}: Условия для стрельбы НЕ выполнены. Пропускаю выстрел.`);
            }
            console.log(`--- Конец оценки для AI Ship ${this.owner.id} ---`);
        } else {
            // Можно добавить лог, если activeEnemies пуст, для полноты картины при отладке
            // console.log(`--- AI Ship ${this.owner.id}: Нет активных врагов для атаки в этот раз. ---`);
        }
    }
} 