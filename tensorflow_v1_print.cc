// Print a tensor easily.
// Usage: op_module.print_identity(<tensor to print>, msg="", filename="", hash=<bool>)
// op_module: the module that contains the print_identity op. i.e. the return value of tf.load_op_library(str(module_file)).
// msg: tensors will be printed with a prefix `Tensor(msg): `.
// filename: tensors are printed to files which name are filename.tensorout. If filename is empty, tensors are printed to stdout.
// hash: whether to print the hash of the tensor. It is useful when you want to compare two extremely large tensors.

// shapes of tensors may be lost after this op, so it is recommanded to reshape the tensor after printing
// _shape = t.shape
// t = op_module.print_identity(t, msg="t", filename="t", hash=True)
// t = tf.reshape(t, _shape)
def tfprint(tensor, msg, filename, hash):
    _shape = tf.shape(tensor)
    tensor = op_module.print_identity(tensor, msg, filename, hash)
    return tf.reshape(tensor, _shape)


//////////////////////////////////////////////////
// python file:
@ops.RegisterGradient("PrintIdentity")
def _print_identity_cc(op, dy):
    return dy


// c++ op file:
REGISTER_OP("PrintIdentity")
    .Attr("T: {float, double, int32}")
    .Input("data: T")
    .Attr("msg: string")
    .Attr("filename: string")
    .Attr("hash: bool")
    .Output("out: T");

// hash value of a float array, float value is truncated to 6 decimal places
// it it recommanded to use `fmtlib` to convert float to string
template<typename T>
std::size_t hash_of(const T* const arr, std::size_t size) {
    std::size_t seed = 0;
    std::stringstream ss;
    ss.precision(6);
    for (std::size_t i = 0; i < size; i++) {
        ss << std::fixed << arr[i];
        //include <fmt/core.h>
        //std::string s = fmt::format("{:.6f}", arr[i]);
        std::string s = ss.str();
        seed ^= std::hash<std::string>()(s) + 0x9e3779b9 + (seed << 6) + (seed >> 2);
        ss.str("");
    }
    return seed;
}

template <typename Device, typename FPTYPE>
class PrintIdentityOp : public OpKernel {
 public:
  explicit PrintIdentityOp(OpKernelConstruction* context) : OpKernel(context) {
    OP_REQUIRES_OK(context,
                   context->GetAttr("msg", &msg));
    OP_REQUIRES_OK(context,
                   context->GetAttr("filename", &filename));
    OP_REQUIRES_OK(context,
                   context->GetAttr("hash", &hash));
  }

  void Compute(OpKernelContext* context) override {
    const Tensor& input_tensor = context->input(0);
    auto input = input_tensor.flat<FPTYPE>();

    int precision = 10;
    if (!filename.empty()) {
      std::ofstream fs(filename + ".tensorout", std::ios::app);
      fs << std::setprecision(precision);
      fs << "Tensor(" << msg << "): ";
      if (hash) {
          fs << hash_of(input.data(), input.size());
      } else {
          for (int i = 0; i < input.size(); ++i) {
              fs << input(i) << " ";
          }
      }
      fs << "\n";
      fs.close();
    } else {
      std::cout << std::setprecision(precision);
      std::cout << "Tensor(" << msg << "): ";
      if (hash) {
          std::cout << hash_of(input.data(), input.size());
      } else {
          for (int i = 0; i < input.size(); ++i) {
              std::cout << input(i) << " ";
          }
      }
      std::cout << "\n";
    }

    // 将输入的Tensor作为输出返回
    Tensor* output_tensor = nullptr;
    OP_REQUIRES_OK(context, context->allocate_output(0, input_tensor.shape(), &output_tensor));
    auto output = output_tensor->flat<FPTYPE>();
    memcpy(output.data(), input.data(), sizeof(FPTYPE) * input.size());
  }
 private:
  std::string msg;
  std::string filename;
  bool hash;
};

#define REGISTER_CPU(T)                                                        \
  REGISTER_KERNEL_BUILDER(                                                     \
      Name("PrintIdentity").Device(DEVICE_CPU).TypeConstraint<T>("T"),        \
      PrintIdentityOp<CPUDevice, T>);

REGISTER_CPU(float);
REGISTER_CPU(double);
REGISTER_KERNEL_BUILDER(                                                     \
        Name("PrintIdentity").Device(DEVICE_CPU).TypeConstraint<int>("T"),        \
        PrintIdentityOp<CPUDevice, int>);

