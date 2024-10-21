import numpy as np
import tensorflow as tf


# 텍스트 파일에서 데이터 읽기 함수 (부호 있는 정수로 변환)
def load_weights_from_txt(file_path, bit_width=8):
    with open(file_path, 'r') as f:
        data = f.read().split()

        # 16진수를 부호 있는 10진수로 변환
        signed_data = []
        for hex_value in data:
            value = int(hex_value, 16)

            # 비트 폭에 따라 음수인지 확인 (2의 보수 표현)
            if value >= (1 << (bit_width - 1)):  # 음수 값일 때
                value -= (1 << bit_width)

            signed_data.append(value)

        # 5x5 배열로 변환 (가중치의 크기가 5x5로 고정된 경우)
        signed_data = np.array(signed_data).reshape(5, 5)

    return signed_data.astype(np.float32)

def load_input_data(file_path):
    with open(file_path, 'r') as f:
        data = f.read().split()
        # 16진수를 10진수로 변환
        data = [int(x, 16) for x in data]
        # 28x28 배열로 변환
        data = np.array(data).reshape(28, 28)
    return data.astype(np.float32)

# 16진수로 변환하여 파일로 저장하는 함수
def save_output_as_hex(output, filename_prefix):
    for channel in range(output.shape[-1]):  # 각 채널별로 처리
        output_channel = output[0, :, :, channel]  # 첫 번째 배치만 사용
        filename = f'{filename_prefix}_channel_{channel}.txt'
        with open(filename, 'w') as f:
            for row in output_channel:
                hex_values = []
                for x in row:
                    # 값을 고정 소수점으로 변환한 뒤 16진수로 표현
                    # 부호 있는 16진수 표현을 위해 int로 변환
                    if x < 0:
                        hex_value = f'{int(x) & 0xFFF:03x}'  # 음수를 12비트로 맞추기
                    else:
                        hex_value = f'{int(x) & 0xFFF:03x}'
                    hex_values.append(hex_value)
                f.write(' '.join(hex_values) + '\n')

# 16진수로 변환하여 파일로 저장하는 함수
def save_output_as_hex2(output, filename_prefix):
    for channel in range(output.shape[-1]):  # 각 채널별로 처리
        output_channel = output[0, :, :, channel]  # 첫 번째 배치만 사용
        filename = f'{filename_prefix}_channel_{channel}.txt'
        with open(filename, 'w') as f:
            for row in output_channel:
                hex_values = []
                for x in row:
                    # 값을 고정 소수점으로 변환한 뒤 16진수로 표현
                    # 부호 있는 16진수 표현을 위해 int로 변환
                    if x < 0:
                        hex_value = f'{int(x) & 0xFFFFF:05x}'  # 음수를 12비트로 맞추기
                    else:
                        hex_value = f'{int(x) & 0xFFFFF:05x}'
                    hex_values.append(hex_value)
                f.write(' '.join(hex_values) + '\n')


# FC 연산 결과를 16진수로 저장하는 함수
def save_flatten_output_as_hex(output, filename):
    with open(filename, 'w') as f:
        for value in output:
            f.write(f'{int(value):03x}\n')

# 텍스트 파일에서 데이터 읽기 함수 (부호 있는 정수로 변환)
def load_fc_weights_from_txt(file_path, bit_width=8):
    with open(file_path, 'r') as f:
        data = f.read().split()

        # 16진수를 부호 있는 10진수로 변환
        signed_data = []
        for hex_value in data:
            value = int(hex_value, 16)

            # 비트 폭에 따라 음수인지 확인 (2의 보수 표현)
            if value >= (1 << (bit_width - 1)):  # 음수 값일 때
                value -= (1 << bit_width)

            signed_data.append(value)

        # 5x5 배열로 변환 (가중치의 크기가 10*48로 고정된 경우)
        signed_data = np.array(signed_data).reshape(10, 48)

    return signed_data.astype(np.float32)
        
# 정수를 위한 비트 시프트 함수
def apply_bit_shift(tensor, shift_amount, fractional_bits=8):
    # 텐서를 정수로 변환 (고정 소수점 방식)
    tensor_int = tf.cast(tensor * (2 ** fractional_bits), tf.int32)

    # 비트 시프트 적용 (>> shift_amount), 이때 반올림 처리 추가
    shifted_tensor = tf.bitwise.right_shift(tensor_int + (1 << (shift_amount - 1)), shift_amount)

    # 다시 부동소수점으로 변환
    result = tf.cast(shifted_tensor, tf.float32) / (2 ** fractional_bits)
    return result

# 부호 있는 정수로 바이어스 데이터 읽기 함수
def load_signed_bias_from_txt(file_path, bit_width=8):
    with open(file_path, 'r') as f:
        data = f.read().split()

        signed_data = []
        for hex_value in data:
            value = int(hex_value, 16)

            # 비트 폭에 따라 음수인지 확인 (2의 보수 표현)
            if value >= (1 << (bit_width - 1)):  # 음수일 때
                value -= (1 << bit_width)

            signed_data.append(value)

        return np.array(signed_data, dtype=np.float32)

# 가중치 파일 경로
conv1_weight_1_path = 'conv1_weight_1.txt'
conv1_weight_2_path = 'conv1_weight_2.txt'
conv1_weight_3_path = 'conv1_weight_3.txt'

# 바이어스 파일 경로
conv1_bias_path = 'conv1_bias.txt'

# 가중치 파일 경로 (두 번째 Conv2D 연산용)
conv2_weight_11_path = 'conv2_weight_11.txt'
conv2_weight_12_path = 'conv2_weight_12.txt'
conv2_weight_13_path = 'conv2_weight_13.txt'
conv2_weight_21_path = 'conv2_weight_21.txt'
conv2_weight_22_path = 'conv2_weight_22.txt'
conv2_weight_23_path = 'conv2_weight_23.txt'
conv2_weight_31_path = 'conv2_weight_31.txt'
conv2_weight_32_path = 'conv2_weight_32.txt'
conv2_weight_33_path = 'conv2_weight_33.txt'

# 바이어스 파일 경로 (두 번째 Conv2D 연산용)
conv2_bias_path = 'conv2_bias.txt'

# FC 레이어 가중치 및 바이어스 파일 경로
fc_weights_path = 'fc_weight.txt'
fc_bias_path = 'fc_bias.txt'

# FC 레이어 가중치 및 바이어스 로드
fc_weights = load_fc_weights_from_txt(fc_weights_path)  # FC_SIZE = 48, OUTPUT_SIZE = 10
fc_bias = load_signed_bias_from_txt(fc_bias_path, bit_width=8)

# 입력 데이터 파일 경로
input_data_path = '0_01.txt'

# 가중치 및 바이어스 데이터 로드
conv1_weight_1 = load_weights_from_txt(conv1_weight_1_path)
conv1_weight_2 = load_weights_from_txt(conv1_weight_2_path)
conv1_weight_3 = load_weights_from_txt(conv1_weight_3_path)

conv1_bias = load_signed_bias_from_txt(conv1_bias_path, bit_width=8)

# 가중치 및 바이어스 데이터 로드 (두 번째 Conv2D 연산용)
conv2_weight_11 = load_weights_from_txt(conv2_weight_11_path)
conv2_weight_12 = load_weights_from_txt(conv2_weight_12_path)
conv2_weight_13 = load_weights_from_txt(conv2_weight_13_path)

conv2_weight_21 = load_weights_from_txt(conv2_weight_21_path)
conv2_weight_22 = load_weights_from_txt(conv2_weight_22_path)
conv2_weight_23 = load_weights_from_txt(conv2_weight_23_path)

conv2_weight_31 = load_weights_from_txt(conv2_weight_31_path)
conv2_weight_32 = load_weights_from_txt(conv2_weight_32_path)
conv2_weight_33 = load_weights_from_txt(conv2_weight_33_path)

conv2_bias = load_signed_bias_from_txt(conv2_bias_path, bit_width=8)

# 입력 데이터 로드
input_data = load_input_data(input_data_path)
input_data = input_data.reshape(1, 28, 28, 1)  # 4D 텐서로 변환

# 필터들을 4차원으로 변환 (필터 크기: 5x5, 입력 채널: 1, 출력 채널: 3)
filters = np.stack([conv1_weight_1, conv1_weight_2, conv1_weight_3], axis=-1).reshape(5, 5, 1, 3)

# 필터와 바이어스를 이용해 Conv2D 연산 수행
conv_layer = tf.nn.conv2d(input_data, filters, strides=[1, 1, 1, 1], padding='VALID') # VALID 설정 -> 24x24

# 비트 시프트 적용 (바이어스를 더하기 전에)
conv_layer_shifted = apply_bit_shift(conv_layer, shift_amount=8)

conv_layer_with_bias = conv_layer_shifted + conv1_bias

# STEP 1: Conv 연산 결과 저장
save_output_as_hex(conv_layer_with_bias, '01_conv1')
print("============= STEP 1 ==============")
print("============= CONV1 ==============")
print("Convolution 1 결과 저장되었습니다.")

# STEP 2: Max Pooling 추가 (2x2 필터, 스트라이드 2, padding='VALID'로 설정)
pooled_layer = tf.nn.max_pool2d(conv_layer_with_bias, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='VALID')

# 중간 결과 저장
save_output_as_hex(pooled_layer, '02_max_pooling_layer1_')

# STEP 3: ReLU 활성화 함수 적용
relu_layer1 = tf.nn.relu(pooled_layer)

# 각 채널별로 결과를 저장 (ReLU 이후)
relu_output1 = relu_layer1

# 중간 결과 저장
save_output_as_hex(relu_output1, '03_relu_layer1_')
print("============= STEP 2 ==============")
print("============= MAX_Pooling & Relu ==============")
print("Max Pooling & Relu 결과 저장되었습니다.")

# 첫 번째 Conv -> MaxPooling -> ReLU의 결과 (12x12x3 크기) 이후 두 번째 Conv 연산에 입력될 텐서로 준비
relu_layer_input = relu_output1  # 이전 레이어에서 나온 12x12x3 데이터를 그대로 사용

# 첫 번째 채널 (channel 0)의 세 개의 필터 적용
conv_layer_0_0 = tf.nn.conv2d(relu_layer_input[:, :, :, 0:1], conv2_weight_11.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')
conv_layer_0_1 = tf.nn.conv2d(relu_layer_input[:, :, :, 0:1], conv2_weight_21.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')
conv_layer_0_2 = tf.nn.conv2d(relu_layer_input[:, :, :, 0:1], conv2_weight_31.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')

# 두 번째 채널 (channel 1)의 세 개의 필터 적용
conv_layer_1_0 = tf.nn.conv2d(relu_layer_input[:, :, :, 1:2], conv2_weight_12.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')
conv_layer_1_1 = tf.nn.conv2d(relu_layer_input[:, :, :, 1:2], conv2_weight_22.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')
conv_layer_1_2 = tf.nn.conv2d(relu_layer_input[:, :, :, 1:2], conv2_weight_32.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')

# 세 번째 채널 (channel 2)의 세 개의 필터 적용
conv_layer_2_0 = tf.nn.conv2d(relu_layer_input[:, :, :, 2:3], conv2_weight_13.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')
conv_layer_2_1 = tf.nn.conv2d(relu_layer_input[:, :, :, 2:3], conv2_weight_23.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')
conv_layer_2_2 = tf.nn.conv2d(relu_layer_input[:, :, :, 2:3], conv2_weight_33.reshape(5, 5, 1, 1), strides=[1, 1, 1, 1], padding='VALID')

# STEP 4: 각 Conv 직후 결과 저장
save_output_as_hex2(conv_layer_0_0, f'04_conv2_00')
save_output_as_hex2(conv_layer_0_1, f'04_conv2_01')
save_output_as_hex2(conv_layer_0_2, f'04_conv2_02')
save_output_as_hex2(conv_layer_1_0, f'04_conv2_10')
save_output_as_hex2(conv_layer_1_1, f'04_conv2_11')
save_output_as_hex2(conv_layer_1_2, f'04_conv2_12')
save_output_as_hex2(conv_layer_2_0, f'04_conv2_20')
save_output_as_hex2(conv_layer_2_1, f'04_conv2_21')
save_output_as_hex2(conv_layer_2_2, f'04_conv2_22')

# 합산
conv_output_0 = conv_layer_0_0 + conv_layer_1_0 + conv_layer_2_0
conv_output_1 = conv_layer_0_1 + conv_layer_1_1 + conv_layer_2_1
conv_output_2 = conv_layer_0_2 + conv_layer_1_2 + conv_layer_2_2

save_output_as_hex2(conv_output_0, f'04_sum1')
save_output_as_hex2(conv_output_1, f'04_sum2')
save_output_as_hex2(conv_output_2, f'04_sum3')

# 합산 결과 배열에 넣기
conv_output = [conv_output_0, conv_output_1, conv_output_2]

# 비트 시프트 적용 (바이어스를 더하기 전에)
conv_output_shifted = [apply_bit_shift(conv_out, shift_amount=8) for conv_out in conv_output]

# 바이어스 더하기
conv_result_with_bias = [conv_shifted + bias for conv_shifted, bias in zip(conv_output_shifted, conv2_bias)]

# STEP 5: 각 채널별 결과 저장
for i, result in enumerate(conv_result_with_bias):
    save_output_as_hex(result, f'05_conv2_sum_channel_{i}')

print("============= STEP 3 ==============")
print("============= Conv2 결과 합산 ==============")
print("Conv2 합산 결과 저장되었습니다.")

# STEP 6: Max Pooling (2x2 필터, 스트라이드 2) 적용
# 각 채널에 대해 개별적으로 Max Pooling을 적용
pooled_layer2_0 = tf.nn.max_pool2d(conv_result_with_bias[0], ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='VALID')
pooled_layer2_1 = tf.nn.max_pool2d(conv_result_with_bias[1], ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='VALID')
pooled_layer2_2 = tf.nn.max_pool2d(conv_result_with_bias[2], ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='VALID')

# 중간 결과 저장
save_output_as_hex(pooled_layer2_0, '06_max_pooling_layer2_channel_0')
save_output_as_hex(pooled_layer2_1, '06_max_pooling_layer2_channel_1')
save_output_as_hex(pooled_layer2_2, '06_max_pooling_layer2_channel_2')

# STEP 7: ReLU 활성화 함수 적용
relu_layer2_0 = tf.nn.relu(pooled_layer2_0)
relu_layer2_1 = tf.nn.relu(pooled_layer2_1)
relu_layer2_2 = tf.nn.relu(pooled_layer2_2)

# 중간 결과 저장
save_output_as_hex(relu_layer2_0, '07_relu_layer2_channel_0')
save_output_as_hex(relu_layer2_1, '07_relu_layer2_channel_1')
save_output_as_hex(relu_layer2_2, '07_relu_layer2_channel_2')

print("============= STEP 4 ==============")
print("============= MAX_Pooling & ReLU (Layer 2) ==============")
print("Max Pooling & ReLU (Layer 2) 결과 저장되었습니다.")

# STEP 8: Flatten (각 채널에 대해 개별적으로)
flattened_output_0 = relu_layer2_0.numpy().flatten()
flattened_output_1 = relu_layer2_1.numpy().flatten()
flattened_output_2 = relu_layer2_2.numpy().flatten()

import numpy as np

# 세 채널의 Flatten 결과를 합침 (Flatten한 후 하나로 연결)
flattened_output = np.concatenate([flattened_output_0, flattened_output_1, flattened_output_2])

# Flatten 결과 저장
save_flatten_output_as_hex(flattened_output, '08_flatten_output')
print("============= STEP 5 ==============")
print("============= Flatten 결과 ==============")
print("Flatten 결과 저장되었습니다.")


# STEP 9: Fully Connected 연산
fc_output = np.matmul(fc_weights, flattened_output) + fc_bias

# FC 연산 결과 저장
save_flatten_output_as_hex(fc_output, '09_fc_output')
print("============= STEP 6 ==============")
print("============= Fully Connected Layer ==============")
print("FC 연산 결과 저장되었습니다.")

# STEP 10: 가장 큰 값의 인덱스 구하기
max_index = np.argmax(fc_output)

# 최종 결과 출력
print("최종 출력 결과:", fc_output)
print("가장 큰 값의 인덱스:", max_index)

# 최종 결과 저장
save_flatten_output_as_hex(fc_output, '10_final_output')

