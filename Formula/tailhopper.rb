class Tailhopper < Formula
  desc "Use multiple Tailscale tailnets at the same time"
  homepage "https://github.com/jcambass/tailhopper"
  url "https://github.com/Jcambass/tailhopper/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "84221ec3f29b01900ea27cdfdefb7baf951fb3ec6807b2a5ccd853dcb63b25f6"
  license "MIT"
  head "https://github.com/jcambass/tailhopper.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/Jcambass/homebrew-tap/releases/download/tailhopper-0.1.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "11408807fdad8a16ca9fbb72351579cc395b9d000a9d2cc9102f6ffa4e1ad813"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "852f79a2ef6be497ac4ccc4e6019adcdf0ecb83b0ef3ccd5350626f117a09b55"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=#{version}"), "./cmd/tailhopper"
    (var/"tailhopper").mkpath
  end

  service do
    run [opt_bin/"tailhopper"]
    environment_variables HTTP_PORT: ENV.fetch("TAILHOPPER_HTTP_PORT", "8888")
    keep_alive true
    working_dir var/"tailhopper"
    log_path var/"log/tailhopper.log"
    error_log_path var/"log/tailhopper.log"
  end

  def caveats
    <<~EOS
      Once Tailhopper is running, you can access:
      - The dashboard at http://localhost:#{ENV.fetch("TAILHOPPER_HTTP_PORT", "8888")}
      - The logs at #{var}/log/tailhopper.log
      - The state file and state folder at #{var}/tailhopper

      To use a custom HTTP port, set the TAILHOPPER_HTTP_PORT environment variable before starting the service:
        export TAILHOPPER_HTTP_PORT=8080

      To stop Tailhopper:
        brew services stop tailhopper

      To uninstall Tailhopper while keeping state/log files:
        brew services stop tailhopper
        brew uninstall tailhopper

      To uninstall Tailhopper while also removing state/log files:
        brew services stop tailhopper
        brew uninstall tailhopper
        rm -rf "$(brew --prefix)/var/tailhopper" "$(brew --prefix)/var/log/tailhopper.log"
    EOS
  end

  test do
    assert_equal "#{version}\n", shell_output("#{bin}/tailhopper --version")
  end
end
