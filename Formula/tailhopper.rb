class Tailhopper < Formula
  desc "Use multiple Tailscale tailnets at the same time"
  homepage "https://github.com/jcambass/tailhopper"
  url "https://github.com/Jcambass/tailhopper/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "294c926363a1a868cf76b648e1b67a03a981b6adc304191b885a0e230f762536"
  license "MIT"
  head "https://github.com/jcambass/tailhopper.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/Jcambass/homebrew-tap/releases/download/tailhopper-0.1.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "71e996d2ef6ef93a9e0bf90f6121889f71475a378ed0ced8fdc989118ec8df8b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9b9f0fd830737223fa1878bf1c12582709ad2a034df2428830dade9fc4031c40"
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
