import tensorflow.compat.v1 as tf
tf.disable_eager_execution()
import numpy as np
np.set_printoptions(threshold=np.inf)

libs = [
        '../../../../build/py37-none-manylinux_2_17_x86_64/op/libop_grads.so',
        '../../../../build/py37-none-manylinux_2_17_x86_64/op/libdeepmd_op.so',
        '../../../../build/py37-none-manylinux_2_17_x86_64/lib/src/cuda/cudart/libdeepmd_dyn_cudart.so',
        '../../../../build/py37-none-manylinux_2_17_x86_64/lib/src/cuda/libdeepmd_op_cuda.so',
        '../../../../build/py37-none-manylinux_2_17_x86_64/lib/libdeepmd.so',
        ]

for l in libs:
    tf.load_op_library(l)

def load_pb(path_to_pb):
    with tf.gfile.GFile(path_to_pb, "rb") as f:
        graph_def = tf.GraphDef()
        graph_def.ParseFromString(f.read())
    with tf.Graph().as_default() as graph:
        tf.import_graph_def(graph_def, name='')
        return graph

# 加载图
graph = load_pb('graph-compress.pb')

names = set(['Const:0', 'Const_1:0', 'Const_2:0', 'Const_3:0']) # 可能有更多的名字，但是都是Const_*:0
with tf.compat.v1.Session(graph=graph) as sess:
    for op in graph.get_operations():
        if op.type == "Const":  # 只检查常量操作
            tensor = op.outputs[0]
            tensor_value = sess.run(tensor)
            if tensor.name in names:
                print(tensor.shape)
                np.savetxt(f"{tensor.name}.csv", tensor_value, delimiter=',')
