<?php

namespace App\Entity\Translation;

use Doctrine\ORM\Mapping as ORM;

use Symfony\Component\Serializer\Annotation\Groups;
use Locastic\ApiPlatformTranslationBundle\Model\AbstractTranslation;

/**
 * @ORM\Entity()
 */
class ServiceTranslation extends AbstractTranslation
{
    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     */
    private $id;

    /**
     * @ORM\ManyToOne(targetEntity="App\Entity\ServiceTree", inversedBy="translations")
     */
    protected $translatable;

    /**
     * @ORM\Column(type="string")
     *
     * @Groups({"service:read", "service:write", "translations"})
     */
    private $label;

    /**
     * @ORM\Column(type="string")
     *
     * @Groups({"service:read", "service:write", "translations"})
     */
    private $description;

    /**
     * @ORM\Column(type="string")
     *
     * @Groups({"service:write", "translations"})
     */
    protected $locale;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getLabel(): ?string
    {
        return $this->label;
    }

    public function setLabel(?string $label): void
    {
        $this->label = $label;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): void
    {
        $this->description = $description;
    }
}