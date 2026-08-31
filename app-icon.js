import * as React from "react";
const SvgAppIcon = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={1024}
    height={1024}
    fill="none"
    {...props}
  >
    <path fill="#141414" d="M0 0h1024v1024H0z" />
    <circle
      cx={512}
      cy={512}
      r={460}
      stroke="#D4AF37"
      strokeWidth={20}
      opacity={0.5}
    />
    <circle
      cx={512}
      cy={512}
      r={440}
      stroke="#D4AF37"
      strokeWidth={5}
      opacity={0.8}
    />
    <g
      stroke="#D4AF37"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={60}
      filter="url(#app_icon_svg__a)"
    >
      <path d="M320 350h230M320 512h180M320 674h230M320 350v324M650 350v324m-50-324h100M600 674h100" />
    </g>
    <defs>
      <filter
        id="app_icon_svg__a"
        width={1024}
        height={1024}
        x={0}
        y={0}
        colorInterpolationFilters="sRGB"
        filterUnits="userSpaceOnUse"
      >
        <feFlood floodOpacity={0} result="BackgroundImageFix" />
        <feColorMatrix
          in="SourceAlpha"
          result="hardAlpha"
          values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
        />
        <feOffset dy={4} />
        <feGaussianBlur stdDeviation={10} />
        <feComposite in2="hardAlpha" operator="out" />
        <feColorMatrix values="0 0 0 0 0.831373 0 0 0 0 0.686275 0 0 0 0 0.215686 0 0 0 0.4 0" />
        <feBlend in2="BackgroundImageFix" result="effect1_dropShadow_1_2" />
        <feBlend
          in="SourceGraphic"
          in2="effect1_dropShadow_1_2"
          result="shape"
        />
      </filter>
    </defs>
  </svg>
);
export default SvgAppIcon;
