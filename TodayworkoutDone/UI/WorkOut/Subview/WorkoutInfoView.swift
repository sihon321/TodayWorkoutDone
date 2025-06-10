//
//  WorkoutInfoView.swift
//  TodayworkoutDone
//
//  Created by ocean on 6/10/25.
//

import SwiftUI

struct WorkoutInfoView: View {
    @Environment(\.popupDismiss) var dismiss
    
    var workout: WorkoutState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(workout.name)
                    .foregroundColor(.black)
                    .font(.system(size: 15))
                    .padding(.top, 12)
                Image("default")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 226, maxHeight: 226)
                Text("설명")
                    .font(.system(size: 18))
                Text("바닥에 놓인 바벨을 팔을 곧게 편 상태로 잡아 엉덩이 높이까지 들어 올리는 웨이트 트레이닝의 대표적인 운동입니다. 스쿼트, 벤치프레스와 함께 파워리프팅의 3대 운동 중 하나로 꼽히며, 전신 근육을 사용하는 복합 운동입니다")
                    .font(.system(size: 15))
                Text("운동 방식과 자세")
                    .font(.system(size: 18))
                Text("""
                    정확한 자세를 유지하는 것이 매우 중요하며, 특히 허리가 둥글게 말리지 않도록 주의해야 합니다
                     •    두 발을 골반 너비로 벌리고 바벨 앞에 선다.
                     •    무릎을 약간 굽히고, 상체를 숙여 바벨을 잡는다.
                     •    허리를 곧게 펴고, 가슴을 내밀며 시선은 정면을 본다.
                     •    바벨을 몸에 최대한 가깝게 유지하며, 엉덩이와 다리의 힘으로 들어 올린다.
                     •    바벨이 허벅지를 지나면서 엉덩이를 앞으로 밀어주며 완전히 선다.
                     •    다시 천천히 바벨을 바닥으로 내린다
                    """)
                    .font(.system(size: 15))
                Text("주요 운동 부위 및 효과")
                    .font(.system(size: 18))
                Text("""
                    데드리프트는 전신운동으로, 특히 다음 부위에 큰 자극을 줍니다.
                    •    둔근(엉덩이 근육: 대둔근, 중둔근, 소둔근)
                    •    햄스트링(허벅지 뒤쪽 근육)
                    •    쿼드러셉스(허벅지 앞쪽 근육)
                    •    등 근육(광배근, 척추기립근 등)
                    •    복부 및 코어 근육
                    """)
                    .font(.system(size: 15))
                Text("데드 리프트의 종류")
                    .font(.system(size: 18))
                Text("""
                    •    컨벤셔널 데드리프트: 가장 기본적인 형태로, 바벨을 바닥에서 들어 올리는 동작.
                    •    루마니안 데드리프트: 바벨을 무릎 정도까지만 내렸다가 들어 올려, 햄스트링과 둔근 자극에 집중.
                    •    스모 데드리프트: 다리를 넓게 벌리고 수행하여, 내전근과 둔근 자극이 강함.
                    •    스티프 레그드 데드리프트: 무릎을 거의 펴고 실시해 햄스트링 자극이 큼
                    """)
                    .font(.system(size: 15))
                Text("주의사항")
                    .font(.system(size: 18))
                Text("""
                    •    무거운 중량보다는 정확한 자세가 우선입니다.
                    •    허리가 굽지 않도록 척추를 일자로 유지해야 하며, 바벨은 항상 몸에 가깝게 붙여야 합니다.
                    •    초보자는 가벼운 중량으로 자세를 충분히 익힌 후 점진적으로 무게를 늘리는 것이 안전합니다
                    """)
                    .font(.system(size: 15))
            }
        }
        .padding(EdgeInsets(top: 37, leading: 24, bottom: 40, trailing: 24))
        .background(Color.white.cornerRadius(20))
        .padding(.horizontal, 40)
    }
}

#Preview {
    WorkoutInfoView(workout: WorkoutState(model: Workout.mockedData[1]))
}
