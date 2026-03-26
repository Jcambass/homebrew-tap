class Tailhopper < Formula
  desc "Use multiple Tailscale tailnets at the same time"
  homepage "https://github.com/jcambass/tailhopper"
  url "https://github.com/Jcambass/tailhopper/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "fa49ca0b7706dca74253de6c4ba7962747158f8fec9eaee8d09e14e5cda43536"
  license "MIT"
  head "https://github.com/jcambass/tailhopper.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/Jcambass/homebrew-tap/releases/download/tailhopper-0.1.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "fb8e3bcab9735f9098dab2e2f6197cabbdeea648abd3794056ac1a66a275dbc1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "18003f648c07413e52d6a103176a5e5d2e82ccd5732e6b8b0ef90164f3f248ce"
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
